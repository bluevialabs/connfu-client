
module Connfu
  module Provisioning

    #
    # This class models a connFu Twitter channel
    #
    class Twitter < Channel

      # Twitter accounts associated to that Twitter channel
      attr_accessor :accounts

      # string that filters the tweets to retrieve only the desired hashtag
      attr_accessor :filter

      def initialize(params)
        super(params)
        self.type = "twitter"
      end

      # Creates a hash with the Twitter instance info
      def to_hash
        {"uid" => uid, "type" => type, "accounts" => accounts, "filter" => filter}
      end

    end
  end
end