
module Connfu

  ##
  # This class provides the relevant information got from an external event
  #
  class Message

    # valid voice messages
    VOICE_TYPES = ["join", "leave", "new_topic"]

    # valid sms messages
    SMS_TYPES = ["sms"]

    attr_reader :id # external identifier
    attr_reader :content # main content
    attr_reader :from # sender
    attr_reader :to # receiver
    attr_reader :message_type # new, join
    attr_reader :channel_type # twitter, voice, sms, rss, etc
    attr_accessor :channel_name # specific channel (twitter account, etc)

    ##
    # Initializer
    def initialize(params)
      params.each_pair { |key, value|
        self.instance_variable_set("@#{key}", value)
      }
    end

    ##
    # Trying to show the information properly
    def to_s
      value = []
      self.instance_variables.each { |var|
        value << "#{var[1..-1]}: #{self.instance_variable_get(var)}"
      }
      value.join("; ").to_s
    end

    ##
    # Retrieve an attribute using a Hash approach
    # ==== Parameters
    # * +value+ attribute name
    # ==== Return
    # attribute value
    def [](value)
      self.instance_variable_get("@#{value.to_s}")
    end

    class << self
      ##
      # Checks if a message is a valid voice message (If it is included in VOICE_TYPES)
      # ==== Parameters
      # * +type+ message type
      # ==== Return
      # true if the message is a voice message, false if not
      def is_voice?(type)
        VOICE_TYPES.include?(type)
      end

      ##
      # Checks if a message is a valid sms message (If it is included in SMS_TYPES)
      # ==== Parameters
      # * +type+ message type
      # ==== Return
      # true if the message is a sms message, false if not
      def is_sms?(type)
        SMS_TYPES.include?(type)
      end
    end

  end
end