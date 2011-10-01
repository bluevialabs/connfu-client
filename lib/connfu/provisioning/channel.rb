
module Connfu
  module Provisioning

    ##
    # Channel class models a connFu application channel. Its the superclass of Twitter and Voice and any other
    # forthcoming connFu channel
    class Channel

      # created at timestamp
      attr_accessor :created_at

      # updated at timestamp
      attr_accessor :updated_at

      # channel unique identifier
      attr_accessor :uid

      # channel type
      attr_accessor :channel_type

      # Creates a Channel instance using a Hash values
      # It creates an instance variable per each hash key
      def initialize(params)
        self.channel_type = self.class.to_s.downcase
        params.each_pair { |key, value|
          self.instance_variable_set("@#{key}", value)
        }
      end

      # Creates a hash with the instance info
      def to_hash
        {"uid" => uid}
      end

      # Print object using metaprogramming. This method is used by any child class
      def to_s
        value = []
        self.instance_variables.each { |var|
          value << "#{var[1..-1]}: #{self.instance_variable_get(var)}"
        }
        self.class.name + "{\n" + value.join("\t\n").to_s + "\n}"
      end

      class << self

        ##
        #
        # Creates a Channel instance (or a Channel child class instance) object or an Array using a Hash values
        #
        # ==== Parameters
        #
        # * +data+ - hash containing channel information retrieved using the connFu API
        def unmarshal(data)
          # Helper to get the channel class using the channel_type attribute (we are
          # retrieving all the channels) or the client class (we are retrieving
          # specific a channel type)
          create_channel = lambda { |channel|
            if channel.has_key?("type") && ListenerChannel::CHANNEL_TYPES.include?(channel["type"].to_sym) # get the class from type attribute (get all channels)
              channel_type = channel["type"].capitalize
              Connfu::Provisioning.const_get(channel_type).new(channel)
            else # get the class from class
              self.new(channel)
            end
          }

          if data.is_a?(Array) # more than one element
            data.map { |channel| create_channel.call(channel) }
          else # one element
            create_channel.call(data)
          end
        end
      end


    end
  end
end