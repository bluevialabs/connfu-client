module Connfu

  module Provisioning

    ##
    # This class defines a whitelist user (whitelist item)
    WhitelistUser = Struct.new(:name, :phone)

    ##
    # This class models a conference whitelist
    class Whitelist

       # WhitelistUser array
      attr_accessor :users

      # Conference phone
      attr_reader :voice

      def initialize(voice, users = [])
        @voice = voice
        @users = users
      end

      # Iterator based on users array
      def each
        users.each{|user|
          yield user
        }
      end

      def to_s
        value = []
        self.instance_variables.each { |var|
          value << "#{var}: #{self.instance_variable_get(var)}"
        }
        value.join("\n").to_s
      end

      ##
      # Creates a Whitelist object using the raw data from the provisioning API
      # ==== Parameters
      # * +voice+ voice channel unique identifier
      # * +data+ raw data retrieved using the connFu API
      def self.unmarshal(voice, data)

        if data.is_a?(Array)
          numbers = []
          data.each { |number|
            numbers << WhitelistUser.new(*number.values)

          }
          users = numbers
        else
          users = [WhitelistUser.new(*data.values)]
        end
        Whitelist.new(voice, users)
      end

    end

  end
end