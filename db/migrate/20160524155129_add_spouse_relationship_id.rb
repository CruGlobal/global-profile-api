class AddSpouseRelationshipId < ActiveRecord::Migration
  def change
    add_column :people, :spouse_rel_id, :uuid
  end
end
