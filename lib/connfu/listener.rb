require 'connfu/connfu_stream'
require 'connfu/connfu_logger'

module Connfu

  ##
  # Class that listen to external events.
  # Delegates the behavior in ConnfuStream so any new external resource
  # can be added and no need to change the interface is required
  #
  class Listener
    include Connfu::ConnfuLogger # application logger

    attr_reader :continue
    attr_reader :counter
    attr_reader :app_stream
    attr_accessor :max_messages # max amount of messages to receive

    ##
    # Listener initializer.
    #
    # ==== Parameters
    # * +queue+ Connfu::Events instance to forward incoming events to be processed by the Dispatcher class
    # * +app_stream+ valid HTTP stream url to connect and listen events
    # * +token+ valid token to get access to a connFu Stream
    # * +stream_endpoint+ endpoint to open a keepalive HTTP connection
    def initialize(queue, app_stream, token, stream_endpoint)
      @connfu_stream = Connfu::ConnfuStream.new(app_stream, token, stream_endpoint)
      @continue = true
      @counter = 0
      @max_messages = 0
      @queue = queue
    end

    ##
    # start listening.
    # Should create a new thread and wait to new events to come
    # ==== Parameters
    # * +queue+ to send incoming events to the Dispatcher class
    def start(queue = nil)
      queue.nil? and queue = @queue
      logger.debug "Listener starts..."

      @thread = Thread.new {
        # listen to connFu
        @connfu_stream.start_listening
      }

      while continue do
        logger.debug "Waiting for a message from connFu stream"
        message = @connfu_stream.get
        @counter = @counter + 1

        logger.debug "#{self.class} got message => #{message}"
        # Write in internal Queue
        queue.put(message)
      end

    end

    ##
    # Wait to get external events
    def join
      @thread.join
    end

    ##
    # stop waiting for external events
    def stop
      @continue = false
    end

    ##
    # checks if the thread should continue listening or return
    def continue
      if max_messages > 0
        @continue and @counter < max_messages
      else
        @continue
      end
    end

  end

end