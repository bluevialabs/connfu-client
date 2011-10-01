module Connfu
  module Provisioning

    # This class models s connFu RSS channel
    class Rss < Channel

      # RSS URI
      attr_accessor :uri

      def initialize(params)
        super(params)
        self.channel_type = "rss"
      end

      def to_hash
        {"uid" => uid, "channel_type" => channel_type, "uri" => uri}
      end

    end
  end
end