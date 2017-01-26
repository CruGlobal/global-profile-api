require 'cru_lib'
require 'cru_lib/async'

module CruLib
  module GlobalRegistryMethods
    extend ActiveSupport::Concern
    include CruLib::Async


    included do
      after_commit :push_to_global_registry
      after_destroy :delete_from_global_registry
    end

    def delete_from_global_registry
      if global_registry_id
        Sidekiq::Client.enqueue(self.class, nil, :async_delete_from_global_registry, global_registry_id)
      end
    end

    # Define default push method
    def push_to_global_registry
      async(:async_push_to_global_registry)
    end

    def async_push_to_global_registry(parent_id = nil, parent_type = nil, parent = nil)
      self.class.push_structure_to_global_registry

      if global_registry_id
        begin
          update_in_global_registry(parent_id, parent_type, parent)
        rescue RestClient::ResourceNotFound
          self.global_registry_id = nil
          async_push_to_global_registry
        end
      else
        create_in_global_registry(parent_id, parent_type, parent)
      end
    end

    def attributes_to_push(*args)
      unless @attributes_to_push
        @attributes_to_push = {}
        attributes_to_push['client_integration_id'] = id unless self.class.skip_fields_for_gr.include?('client_integration_id')
        attributes_to_push['client_updated_at'] = updated_at if respond_to?(:updated_at)
        attributes.collect {|k, v| @attributes_to_push[k.underscore] = self.class.gr_value(k.underscore, v)}
        @attributes_to_push.select! {|k, v| v.present? && !self.class.skip_fields_for_gr.include?(k)}
      end
      @attributes_to_push
    end

    def update_in_global_registry(parent_id = nil, parent_type = nil, parent = nil)
      if parent_type
        create_in_global_registry(parent_id, parent_type, parent)
      else
        GlobalRegistry::Entity.put(global_registry_id, {entity: attributes_to_push})
      end
    end

    def create_in_global_registry(parent_id = nil, parent_type = nil, parent = nil)
      entity_attributes = { self.class.global_registry_entity_type_name => attributes_to_push }
      if parent_type.present?
        entity_attributes = {parent_type => entity_attributes.merge(client_integration_id: parent.id)}
        GlobalRegistry::Entity.put(parent_id, {entity: entity_attributes})
      else
        entity = GlobalRegistry::Entity.post(entity: entity_attributes)
        global_registry_id = entity['entity'][self.class.global_registry_entity_type_name]['id']
        update_column(:global_registry_id, global_registry_id)
      end
    end

    module ClassMethods
      def gr_value(column_name, value)
        return value if value.blank?

        column = columns_to_push.detect { |c| c[:name] == column_name }
        return unless column

        case column[:field_type].to_s
        when 'datetime', 'date'
          value.to_s(:db)
        when 'boolean'
          value ? 'true' : 'false'
        else
          value.to_s.strip
        end
      end

      def push_structure_to_global_registry(parent_id = nil)
        # Make sure all columns exist
        entity_type = Rails.cache.fetch(global_registry_entity_type_name, expires_in: 1.hour) do
          GlobalRegistry::EntityType.get(
            {'filters[name]' => global_registry_entity_type_name, 'filters[parent_id]' => parent_id}
          )['entity_types'].first
        end
        if entity_type
          existing_fields = entity_type['fields'].collect {|f| f['name']}
        else
          entity_type = GlobalRegistry::EntityType.post(entity_type: {name: global_registry_entity_type_name, parent_id: parent_id, field_type: 'entity'})['entity_type']
          existing_fields = []
        end

        columns_to_push.each do |column|
          unless existing_fields.include?(column[:name])
            GlobalRegistry::EntityType.post(entity_type: {name: column[:name], parent_id: entity_type['id'], field_type: column[:type]})
          end
        end
      end

      def columns_to_push
        @columns_to_push ||= columns.select { |c|
          !skip_fields_for_gr.include?(c.name.underscore)
        }.collect {|c|
          { name: c.name.underscore, field_type: normalize_column_type(c.type, c.name.underscore) }
        }
      end

      def normalize_column_type(column_type, name)
        case
        when column_type.to_s == 'text'
          'string'
        when name.ends_with?('_id')
          'uuid'
        else
          column_type
        end
      end

      def async_delete_from_global_registry(registry_id)
        begin
          GlobalRegistry::Entity.delete(registry_id)
        rescue RestClient::ResourceNotFound
          # If the record doesn't exist, we don't care
        end
      end

      def global_registry_entity_type_name
        to_s.underscore
      end

      def skip_fields_for_gr
        %w(id global_registry_id created_at updated_at)
      end

    end
  end
end

