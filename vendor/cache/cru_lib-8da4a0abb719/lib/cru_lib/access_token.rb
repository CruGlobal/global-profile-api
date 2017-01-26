require 'securerandom'

module CruLib
  class AccessToken < ActiveModelSerializers::Model
    attr_accessor :key_guid, :relay_guid, :guid, :email, :first_name, :last_name, :token, :pgt

    def initialize(attributes = {})
      attributes.symbolize_keys!
      super(attributes)
      @token = generate_access_token unless attributes[:token]
      write
    end

    class << self

      def read(token)
        json = exist?(token)
        new(Oj.load(json)) if json
      end

      def exist?(token)
        redis_client.get(redis_key(token))
      end

      def redis_client
        @redis_client ||= CruLib.redis_client
      end

      def redis_key(token)
        ['cru_lib', 'access_token', token].join(':')
      end

      def del(token)
        redis_client.del(redis_key(token))
      end
    end

    private

    def generate_access_token
      loop do
        attributes[:token] = SecureRandom.uuid.gsub(/\-/, '')
        break unless self.class.exist?(attributes[:token])
      end
      attributes[:token]
    end

    def write
      self.class.redis_client.setex(self.class.redis_key(attributes[:token]), 30.minutes.to_i, to_json)
    end
  end
end
