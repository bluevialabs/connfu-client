
module Connfu

  module Provisioning

    ##
    # This class models a connFu Voice channel
    #
    class Voice < Channel

      class Privacy
        WHITELIST = "whitelisted"
        PUBLIC = "public"
      end
      
      # Voice channel attributes that could be updated
      UPDATE_ATTRIBUTES = ["topic", "welcome_message", "rejected_message", "privacy", "type"]

      _values = UPDATE_ATTRIBUTES.dup
      _values.each { |value|
        UPDATE_ATTRIBUTES << value.to_sym
      }
      UPDATE_ATTRIBUTES.freeze
      UPDATE_ATTRIBUTES.each { |value| value.freeze }

      # current topic
      attr_accessor :topic

      # welcome message for valid users while joining the conference
      attr_accessor :welcome_message

      # rejected message for invalid users while trying to join the conference
      attr_accessor :rejected_message

      # Identifies if the conference is open to any phone number or users must 
      # be whitelisted to join the conference
      attr_accessor :privacy

      def initialize(params)
        super(params)
        self.channel_type = "voice"
      end

      def to_hash
        {"uid" => uid, "channel_type" => channel_type, "phones" => phones.map(&:to_hash)}
      end

      # access the Voice channel Whitelist
      def whitelist
        Whitelist.new(@name)
      end
      
      # Retrieves the phone numbers
      def phone_number
        values = phones.collect{|phone| phone[:phone_number]}
      end

      def phones
        @phones||=[]
      end

      def phones=(_phones)
        @phones=_phones
      end

      def <<(phone)
        phones << phone
      end

      class << self

        # Creates a Voice object or an Array using a Hash values
        def unmarshal(data)
          obj = super(data)
          if obj.is_a?(Array) # more than one element
            obj.each { |voice|
              voice.phones = voice.phones.map { |phone| Phone.new(voice.uid, phone["phone_number"], phone["country"]) }
            }
          else # one element
            obj.phones = obj.phones.map { |phone| Phone.new(obj.uid, phone["phone_number"], phone["country"]) }
            obj
          end
        end
      end

    end
  end
end