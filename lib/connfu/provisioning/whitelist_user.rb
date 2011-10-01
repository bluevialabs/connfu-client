module Connfu
  module Provisioning
    ##
    # This class defines a whitelist user (whitelist item)
    class WhitelistUser < Struct.new(:name, :phone)

      ##
      # Creates a WhitelistUser object using the raw data from the provisioning API
      # ==== Parameters
      # * +data+ raw data retrieved using the connFu API
      def self.unmarshal(data)
        WhitelistUser.new(*data.values)
      end

    end
    
  end
end