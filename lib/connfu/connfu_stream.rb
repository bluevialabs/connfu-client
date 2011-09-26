require 'active_support'
require 'net/http'
require 'net/https'
require 'uri'
require 'thread'
require 'connfu/connfu_logger'
require 'connfu/message'
require 'connfu/connfu_message_formatter'

module Connfu

  ##
  # Open an HTTP connection to connFu and start listening to any incoming event
  # This is the entry point to execute any proc in a connFu application
  # based on external events.
  class ConnfuStream
    include Connfu::ConnfuLogger # application logger

    ##
    # ConnfuStream initializer.
    # ==== Parameters
    #
    # * +app_stream+ valid HTTP stream url to connect and listen events
    # * +api_key+ valid Token to get access to a Connfu Stream
    # * +uri+ HTTP endpoint to open the connection
    def initialize(app_stream, api_key, uri)

      @app_stream = app_stream
      @api_key = api_key

      _uri = URI.parse(uri)
      @port = _uri.port
      @host = _uri.host
      @path = _uri.path.concat(app_stream)
      @scheme = _uri.scheme

      @formatter = Connfu::ConnfuMessageFormatter
    end

    ##
    # Open a HTTP connection to connFu and start listening new events
    def start_listening

      begin
        # http client instantiation and configuration
        http_client = Net::HTTP.new(@host, @port)
        logger.debug("#{self.class} opening connection to  #{@host}:#{@port}")
        http_client.use_ssl = @scheme.eql?("https")
        if @scheme.eql?("https")
          http_client.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        logger.debug("#{self.class} start listening to stream #{@path}")

        http_client.read_timeout = 60*6 # double the timeout connFu is configured

        # open connection
        http_client.start do |http|
          req = Net::HTTP::Get.new(
              @path,
              headers)

          # send GET request
          http.request(req) do |res|
            logger.debug "#{self.class} Request to the endpoint...."
            # read chunk data
            logger.debug "#{self.class} Waiting for a new event...."
            res.read_body do |chunk|
              unless chunk.chomp.strip.empty?
                # format data retrieved
                events = handle_data(chunk)
                # Insert message(s) in the queue
                events.nil? or message(events)
              else
                logger.debug "#{self.class} got an empty data"
              end
              logger.debug "#{self.class} Waiting for a new event...."
            end
          end
        end
      rescue Exception => ex
        logger.error "[#{Time.now} | #{ex.class}] #{ex.message}\n#{ex.backtrace.join("\n")}"
        # loop again
        start_listening
      end
    end

    ##
    # This method should be called by the class that instantiates the ConnfuStream to fetch inbound events.
    # It stops the execution waiting for an inbound event.
    #
    # ==== Return
    # Connfu::Message instance
    def get
      queue.pop
    end

    private

    ##
    # Internal Queue to send Message instances to the listener
    #
    # ==== Return
    # Queue instance
    def queue
      @queue ||= Queue.new
    end

    ##
    # Process the data retrieved, formatting the raw data into one or more Connfu::Message instances
    #
    # ==== Parameters
    # * +chunk+ data got from the HTTP stream
    #
    # ==== Return
    # * Array of Connfu::Message instances
    # * nil if invalid data
    def handle_data(chunk)
      if chunk.nil?
        logger.info("Unable to process nil data")
        return nil
      end
      logger.debug("raw data #{chunk}")
      chunk = chunk.split("\n") # more than one event can be retrieved separated by '\n'
      if chunk.is_a?(Array)
        events = []
        temp_events = []
        chunk.each { |value|
          json = ActiveSupport::JSON.decode(value)
          if json
            unless json.is_a?(Array) # Twitter - RSS message
              unless json.nil?
                logger.debug("#{self.class} Got a twitter message")
                temp_events << @formatter.format_message(json)
                temp_events.nil? or events << temp_events.flatten
              else
                logger.debug("#{self.class} Invalid data received")
                events = nil
              end
            else # Voice - SMS message
              logger.debug("#{self.class} Got a voice/sms message")
              logger.debug(json)
              temp_events = @formatter.format_voice_sms(json)
              temp_events.nil? or events << temp_events.flatten
            end
          end
        }
        events.flatten
      else
        logger.info("#{self.class} Invalid data received #{chunk}")
        nil
      end
    end

    ##
    # Insert an array of messages in the queue
    # ==== Parameters
    # * +events+ array of incoming events
    def message(events)
      if events.is_a?(Array)
        events.each { |msg|
          if msg.is_a?(Connfu::Message)
            logger.debug("#{self.class} Inserting message in the queue")
            logger.debug msg.to_s
            queue << msg
          else
            logger.info("Invalid message type #{msg.class}")
          end
        }
      end
    end

    ##
    # Headers to send to authenticate
    def headers
      {"accept" => "application/json",
       "authorization" => "Backchat #{@api_key}",
       "Connection" => "Keep-Alive"}
    end

  end
end
