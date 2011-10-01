module Connfu

  module Provisioning

    #
    # connFu Dtmf press key (belongs to a Voice channel)
    #
    class Dtmf

      # tone
      attr_accessor :tone

      # message
      attr_accessor :message

      # voice channel unique identifier
      attr_reader :voice

      # @param voice voice channel identifier
      # @param tone
      # @param message
      def initialize(voice, tone, message = "")
        @voice = voice
        @tone = tone
        @message = message
      end
      
      # Hash way to retrieve attributes
      def [](value)
        self.respond_to?(value.to_sym) ? self.send(value.to_sym) : nil
      end

      def to_hash
        {"tone" => tone, "message" => message}
      end

      def to_s
        "#{self.class.to_s}: #{to_hash}"
      end

      #
      # Creates a Dtmf object using the raw data from the provisioning API
      # @param voice channel unique identifier
      # @param data Hash containing the raw data
      def self.unmarshal(voice, data)
        if data.is_a?(Array)
          data.map{|item| Dtmf.new(voice, item["tone"], item["message"])}
        else
          Dtmf.new(voice, data["tone"], data["message"])
        end
      end

    end
  end
end