##
# connFu is a platform of Telefonica delivered by Bluevia Labs.
#
# Please, check out www.connfu.com and if you need further information
# contact us at mailto:support@connfu.com

require 'connfu/connfu_logger'

module Connfu
  include Connfu::ConnfuLogger
  
  autoload :ConnfuMessageFormatter, 'connfu/connfu_message_formatter'
  autoload :ConnfuStream, 'connfu/connfu_stream'
  autoload :Dispatcher, 'connfu/dispatcher'
  autoload :DSL, 'connfu/dsl'
  autoload :Events, 'connfu/events'
  autoload :Listener, 'connfu/listener'
  autoload :ListenerChannel, 'connfu/listener_channel'
  autoload :Provisioning, 'connfu/provisioning'


  # connFu provisioning API endpoint
  CONNFU_ENDPOINT = "https://api.connfu.com/v1"
  
  # connFu HTTP streaming API endpoint
  STREAM_ENDPOINT = "https://stream.connfu.com/"

  class << self

    # The token defines the application that is using the connFu platform.
    # Get a valid one using connfu portal
    attr_reader :token

    # Hash that keeps information about the blocks to be executed when a new event is thrown
    attr_reader :listener_channels

    # Hash that keeps information about the connFu application channels
    attr_reader :app_channels

    # events dispatcher handler
    attr_accessor :dispatcher

    # events listener. It gets incoming events and forward them to the dispatcher layer
    attr_accessor :listener

    ##
    # This method is used to start a connFu application.
    # Check the examples folder to find some code snippets.
    #
    # ==== Parameters
    #
    # * +token+ valid application token got from connfu
    # * +endpoint+ connFu endpoint (valid provisioning API endpoint)
    # * +stream_endpoint+ connFu streaming endpoint
    def application(token, endpoint = CONNFU_ENDPOINT, stream_endpoint = STREAM_ENDPOINT)
      @token = token
      @listener_channels = {}
      @app_channels = []
      @endpoint = endpoint
      
      # set the log level to DEBUG if we are in debug mode
      $DEBUG and self.log_level=Logger::DEBUG

      logger.info("Starting application with token #{token}")

      # stop if invalid token
      stream = nil
      begin
        app_info = prov_client.get_info
      rescue RestClient::Unauthorized => ex
        logger.error("Invalid token provided")
        logger.error(ex.inspect)
        raise "Token is invalid"
      rescue Exception => ex
        logger.error("Error retrieving application info")
        logger.error(ex.inspect)
        raise "Token is invalid"
      end

      app_info.nil? and raise "Unable to find application data"

      app_stream = app_info.stream_name

      channels = prov_client.get_channels

      # Get the interesting channel data using the channel specific method to_hash
      @app_channels = channels.map { |channel| channel.to_hash }

      # Duplicate voice channels to sms channels
      sms = channels.select { |channel| channel.type.eql?("voice") }
      sms.map!{|channel| channel.type = "sms"; channel.to_hash}

      sms.each{|channel|
        @app_channels << channel
      }

      logger.debug "The application #{app_info.name} has these channels: #{@app_channels}"

      if block_given?

        # Load the listening channels defined using the DSL
        @listener_channels = DSL.run &Proc.new
        
        # This Queue will be used by the listener to put events
        # and by the dispatcher to handle them
        events = Connfu::Events.new
        
        # Start the dispatcher
        @dispatcher = Connfu::Dispatcher.new(events, self.listener_channels, self.app_channels)
        @dispatcher.start

        # Start the listener
        @listener = Connfu::Listener.new(events, app_stream, token, stream_endpoint)
        @listener.start
        
        @listener.join # wait for incoming events
        @dispatcher.join
      end

      # Return the module
      self
    end

    private

    ##
    # Provisioning client to retrieve application valid streams
    def prov_client
      # create client instance to retrieve valid streams
      @prov_client ||= Connfu::Provisioning::Application.new(@token, @endpoint)
    end

  end
end
