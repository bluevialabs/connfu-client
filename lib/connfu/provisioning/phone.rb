module Connfu

  module Provisioning

    #
    # connFu Phone (belongs to a Voice channel)
    #
    class Phone

      # specific country where the phone is allocated
      attr_accessor :country

      # phone number
      attr_accessor :phone_number

      # voice channel unique identifier
      attr_reader :voice

      # @param voice voice channel identifier
      # @param phone_number
      # @param country
      def initialize(voice, phone_number, country = "")
        @voice = voice
        @phone_number = phone_number
        @country = country
      end
      
      # Hash way to retrieve attributes
      def [](value)
        self.respond_to?(value.to_sym) ? self.send(value.to_sym) : nil
      end

      def to_hash
        {"country" => country, "phone_number" => phone_number}
      end

      def to_s
        "#{self.class.to_s}: #{to_hash}"
      end

      #
      # Creates a Phone object using the raw data from the provisioning API
      # @param voice channel unique identifier
      # @param data Hash containing the raw data
      def self.unmarshal(voice, data)
        if data.is_a?(Array)
          data.map{|item| Phone.new(voice, item["phone_number"], item["country"])}
        else
          Phone.new(voice, data["phone_number"], data["country"])
        end
      end

    end
  end
end