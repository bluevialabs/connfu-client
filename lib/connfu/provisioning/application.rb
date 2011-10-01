require 'active_support'

module Connfu
  module Provisioning

    ##
    # Application class defines the single entry point to fetch, create, update and delete
    # any channel associated to the application
    #
    class Application
      # Base instance to send HTTP requests to connFu API
      attr_accessor :base
      
      ##
      # Initializer
      # ==== Parameters
      #
      # * +api_key+ valid api_key that authenticates the application
      # * +endpoint+ connFu endpoint (host:port). Optional
      def initialize(api_key, endpoint = Connfu::CONNFU_ENDPOINT)
        @base = Base.new(api_key, endpoint)
        @name = nil
        @description = nil
        @stream_name = nil
      end

      ##
      # Retrieves the app information using the API
      # ==== Return
      # * +self+ instance with name, description and stream_name updated
      # * raise RestClient::Unauthorized if token is invalid
      def get_info
        if @name.nil?
          data = ActiveSupport::JSON.decode(@base.get(""))
          unless data.nil? or !data.instance_of?(Hash)
            @name = data["name"]
            @description = data["description"]
            @stream_name = data["stream_name"]
          end
        end
        self
      end

      ##
      # Returns the app name. Lazy loading, it sends a request to retrieve application info 
      # only the first time this method is called, and the info is cached for next calls
      # ==== Return
      # application name
      def name
        @name.nil? and get_info
        @name
      end


      ##
      # Returns the app description. Lazy loading, it sends a request to retrieve application info 
      # only the first time this method is called, and the info is cached for next calls
      # ==== Return
      # application description
      def description
        @name.nil? and get_info
        @description
      end

      ##
      # Returns the app stream name. Lazy loading, it sends a request to retrieve application info 
      # only the first time this method is called, and the info is cached for next calls
      # ==== Return
      # application stream name
      def stream_name
        @name.nil? and get_info
        @stream_name
      end

      ##
      # Retrieves the app channels
      # ==== Return
      # Array of Channel instances
      def get_channels
        data = ActiveSupport::JSON.decode(@base.get("channels/"))
        Channel.unmarshal(data)
      end

      #
      # Twitter channel management
      #
      # Retrieve the Twitter channel
      # @param key Twitter channel identifier. It it is not specified, all the twitter channels are fetched
      #
      def get_twitter_channel(key = "")
        data = ActiveSupport::JSON.decode(@base.get("channels/twitter/#{key}"))
        Twitter.unmarshal(data)
      end

      #
      # @TODO
      #
      def update_twitter_channel()

      end

      ##
      # Create a Twitter channel per each of the origin or recipients
      #
      # ==== Parameters
      #
      # * +key+ Twitter channel identifier
      # * +params+ Twitter channel behavior
      #   - array object of origin twitter accounts
      #   - Hash object
      #     - origin: one or more twitter accounts
      #     - mentions: one or more twitter accounts
      #     - hashtags: one or more hashtags
      def create_twitter_channel(key, params = {:origin => [], :mentions => [], :hashtags => []})

        if params.is_a?(Array)
          _params = {}
          _params[:origin] = params
          params = _params
        elsif params.is_a?(String)
          _params = {}
          _params[:origin] = params
          params = _params
        end

        unless params.has_key?(:origin) or params.has_key?(:mentions)
          raise "Invalid parameters. Either origin or mentions should be defined"
        end

        if params.has_key?(:origin) and params.has_key?(:mentions)
          raise "Invalid parameters. Only origin or mentions can be defined"
        end

        filter = []

        # filter = "tags:(tag1 AND tag2...)
        if params.has_key?(:hashtags) && params[:hashtags].respond_to?(:length) && params[:hashtags].length > 0
          filter << "tags:(#{params[:hashtags].map { |hashtag| "#{hashtag}" }.join(" AND ")})"
        end

        if params.has_key?(:origin)
          # retrieve all the tweets from/to that user
          if filter.empty?
            filter = ""
          else
            filter = filter.join(' AND ')
          end
          if params[:origin].is_a?(String)
            users = [params[:origin]]
          else
            users = params[:origin]
          end

          data = @base.post("channels/twitter",
                     {:uid => key,
                      :accounts => users.collect { |item| {:name => item} },
                      :filter => filter
                     })
          Twitter.unmarshal(ActiveSupport::JSON.decode(data))
        else
          # retrieve users mentions
          users = params[:mentions]
          locations = []
          # create a stream per each origin
          users.each { |user|
            user_filter = filter.dup
            user_filter << "recipients:#{user}"

            data = @base.post("channels/twitter",
                                    {:uid => key,
                                     :accounts => [{:name => user}],
                                     :filter => "(#{user_filter.join(' AND ')})"
                                    })
            locations << Twitter.unmarshal(ActiveSupport::JSON.decode(data))
          }
          locations
        end

      end

      ##
      # Delete a Twitter channel
      #
      # ==== Parameters
      # * +key+ twitter channel unique identifier
      # === Return
      # * nil if success
      # * RestClient exception with relevant error information
      def delete_twitter_channel(key)
        @base.delete("channels/twitter/#{key}")
      end

      #
      # Voice channel management
      #
      # Retrieve the voice channel
      # @param voice Voice channel identifier. It it is not specified, all the voice channels are fetched
      #
      def get_voice_channel(voice = "")
        data = @base.get("channels/voice/#{voice}")
        data = ActiveSupport::JSON.decode(data)
        Voice.unmarshal(data)
      end

      #
      # Update the voice channel topic
      # @param voice Voice channel identifier
      # @param params
      #     String: topic new topic
      #     Hash:
      #        topic new topic
      #        welcome_message new welcome_message
      #        rejected_message new rejected_message
      #
      def update_voice_channel(voice, params)
        attributes = {}
        if params.is_a?(String)
          attributes[:topic] = params
        elsif params.is_a?(Hash)
          Voice::UPDATE_ATTRIBUTES.each { |attr|
            params.has_key?(attr) and attributes[attr] = params[attr]
          }
        else
          # do nothing, raise exception...
        end
        @base.put("channels/voice/#{voice}", attributes)
      end

      ##
      # Create a new voice channel
      # ==== Parameters
      # * +name+ voice channel identifier
      # * +country+ country to allocate a DID
      #
      def create_voice_channel(name, country, privacy = Voice::Privacy::WHITELIST)
        Voice.unmarshal(ActiveSupport::JSON.decode(@base.post("channels/voice", {:uid => name, :country => country, :privacy => privacy})))
      end

      ##
      # Delete a voice channel
      # ==== Parameters
      # * +name+ voice channel identifier
      #
      def delete_voice_channel(voice)
        @base.delete("channels/voice/#{voice}")
      end

      # Voice channel Phone Management

      ##
      # Retrieve a voice channel phone lists, that's the list of phones assigned to that voice channel
      # ==== Parameters
      # * +voice+ Voice channel identifier
      # * +phone+ (optional) specific Phone number to retrieve. If it is not specified, all the list is fetched
      def get_phones(voice, phone = "")
        Phone.unmarshal(voice, ActiveSupport::JSON.decode(@base.get("channels/voice/#{voice}/phones/#{phone}")))
      end

      ##
      # Delete one phone number or the whole phone list
      # ==== Parameters
      # * +voice+: Voice channel identifier
      # * +phone+: specific number to delete.
      def delete_phone(voice, phone)
        @base.delete("channels/voice/#{voice}/phones/#{phone}")
      end

      ##
      # Add a new phone number to the Voice channel
      # ==== Parameters
      # * +voice+: Voice channel identifier
      # * +country+: for the phone number to be allocated
      def add_phone(voice, country)
        @base.post("channels/voice/#{voice}/phones", {:country => country})
      end

      ##
      # Retrieve a voice channel dtmf tones, that's the list of actions associated to a IVR voice channel
      # ==== Parameters
      # * +voice+ Voice channel identifier
      # * +dtmf+ (optional) specific Dtmf tone to retrieve. If it is not specified, all the list is fetched
      def get_dtmf(voice, dtmf = "")
        Dtmf.unmarshal(voice, ActiveSupport::JSON.decode(@base.get("channels/voice/#{voice}/dtmf/#{dtmf}")))
      end

      ##
      # Delete one dtmf action or the whole dtmf actions
      # ==== Parameters
      # * +voice+: Voice channel identifier
      # * +dtmf+: specific dtmf tone to delete.
      def delete_dtmf(voice, dtmf)
        @base.delete("channels/voice/#{voice}/dtmf/#{dtmf}")
      end

      ##
      # Add a new dtmf action to the Voice channel
      # ==== Parameters
      # * +voice+: Voice channel identifier
      # * +dtmf+: for the phone number to be allocated
      def add_dtmf(voice, tone, message)
        @base.post("channels/voice/#{voice}/dtmf", {:tone => tone, :message => message})
      end

      ##
      # Voice channel Whitelist management
      #
      # Retrieve the whitelist
      # @param voice Voice channel identifier
      # @param number (optional) specific whitelist number to retrieve. If it is not specified, all the list is fetched
      def get_whitelist(voice, number = "")
        if number.empty?
          Whitelist.unmarshal(voice, ActiveSupport::JSON.decode(@base.get("channels/voice/#{voice}/whitelisted/#{number}")))
        else
          user = ActiveSupport::JSON.decode(@base.get("channels/voice/#{voice}/whitelisted/#{number}"))
          WhitelistUser.new(*user.values)
        end
      end

      #
      # Delete one whitelist number or the whole whitelist
      # @param voice Voice channel identifier
      # @param number (optional) specific number to delete. If not present, the whole whitelist is deleted
      def delete_whitelist(voice, number = "")
        @base.delete("channels/voice/#{voice}/whitelisted/#{number}")
      end

      ##
      # Create a new item in the whitelist
      # ===== Parameters
      # * *args:
      #      - First parameter: voice channel identifier
      #      - Second parameter can be either:
      #          - WhitelistUser object with the name and phone information
      #          - two arguments name, phone
      #
      # ==== Return
      # * Whitelist object
      def add_whitelist(*args)
        voice_id = args[0]
        if args.length.eql?(2)
          whitelist = @base.post("channels/voice/#{voice_id}/whitelisted", {:name => args[1].name, :phone => args[1].phone})
        else
          whitelist = @base.post("channels/voice/#{voice_id}/whitelisted", {:name => args[1], :phone => args[2]})
        end
        WhitelistUser.unmarshal(ActiveSupport::JSON.decode(whitelist))
      end

      #
      # Update a whitelist item
      # @param *args:
      #      - First parameter: voice channel identifier
      #      - Second parameter can be either:
      #          - WhitelistUser object with the name and phone information
      #          - two arguments name, phone
      #
      def update_whitelist(*args)
        if args.length.eql?(2)
          @base.put("channels/voice/#{args[0]}/whitelisted/#{args[1].phone}", {:name => args[1].name})
        else
          @base.put("channels/voice/#{args[0]}/whitelisted/#{args[2]}", {:name => args[1]})
        end
      end

      #
      # RSS channel management
      #
      # Retrieve the rss channel
      # @param name RSS channel identifier. It it is not specified, all the RSS channels are fetched
      #
      def get_rss_channel(name = "")
        data = @base.get("channels/rss/#{name}")
        data = ActiveSupport::JSON.decode(data)
        Rss.unmarshal(data)
      end

      #
      # Create a new rss channel
      # @param name rss channel identifier
      # @param uri RSS endpoint
      #
      def create_rss_channel(name, uri)
        data = @base.post("channels/rss", {:uid => name, :uri => uri})
        data = ActiveSupport::JSON.decode(data)
        Rss.unmarshal(data)
      end

      #
      # Update the rss channel URI
      # @param name RSS channel identifier
      # @param uri new uri
      #
      def update_rss_channel(name, uri)
        @base.put("channels/rss/#{name}", {:uri => uri})
      end

      #
      # Delete a rss channel
      # @param name rss channel identifier
      #
      def delete_rss_channel(name)
        @base.delete("channels/rss/#{name}")
      end

    end

  end
end