require 'connfu/connfu_logger'

module Connfu

  ##
  # Class that dispatches the external events.
  # Currently there is no thread pool, so each event is executed sequentially
  class Dispatcher
    include Connfu::ConnfuLogger

    attr_reader :continue
    attr_reader :counter
    attr_accessor :max_messages

    ##
    # Initializer
    #
    # ==== Parameters
    # * +queue+ Connfu::Events instance to wait for incoming Message events
    # * +listener_channels+ Hash of listener_channels.
    #   * :key => channel name (valid ListenerChannel::CHANNEL_TYPES)
    #   * :value => ListenerChannel instance
    # * +app_channels+ information about application channels to set the channel_name associated to an inbound event
    def initialize(queue, listener_channels, app_channels = [])
      if listener_channels.nil? or !listener_channels.is_a?(Hash) or listener_channels.length == 0
        raise Exception, "Unable to dispatch events if no channel is defined"
      end

      @continue = true
      @counter = 0
      @max_messages = 0
      @listener_channels = listener_channels
      @app_channels = app_channels
      logger.debug("Dispatcher initializer")
      @queue = queue
    end

    ##
    # start waiting for incoming Message.
    # Should create a new thread and wait to new events to come
    # ==== Parameters
    # * +queue+ optional Connfu::Events instance to wait for incoming Message events. If nil, the value got in the initializer is used
    def start(queue = nil)
      queue.nil? and queue = @queue
      logger.debug("Dispatcher starts")
      @thread = Thread.new {
        while continue
          logger.debug("Dispatcher waiting for a message from the Listener")
          event = queue.get
          @counter = @counter + 1
          logger.debug "---------------------------------"
          logger.debug "#{self.class} => #{event}"

          if event.is_a?(Array)
            event.each { |ev|
              set_channels!(ev)
              process_message(ev)
            }
          else
            set_channels!(event)
            process_message(event)
          end

        end
      }
    end

    ##
    # This method should be called for the thread that started the dispatcher
    # in order to wait for dispatching incoming events from the listener
    def join
      @thread.join
    end

    ##
    # Stop waiting for incoming events
    def stop
      @continue = false
    end

    private

    ##
    # Helper to validate if dispatcher should wait for new messages
    def continue
      if max_messages > 0
        @continue and @counter < max_messages
      else
        @continue
      end
    end

    ##
    # Sets the message channel_name attribute. 
    # The result is a list of application channels that should be advised about
    # the inbound message
    #
    # * if message["type"].eql?("twitter"): message["channel_type"] is an 
    # array of all the application twitter channels that has associated the message twitter account.
    #   i.e.
    #     Application channels: 
    #       @app_channels = [
    #                 {"uid"=>"twitter-channel-1", "type"=>"twitter", "accounts"=>[{"name"=>"juandebravo"}, {"name"=>"connfudev"}]},
    #                 {"uid"=>"twitter-channel-2", "type"=>"twitter", "accounts"=>[{"name"=>"telefonicaid"}]}]
    #     Incoming message:
    #       message.channel_type = "twitter"
    #       message.from = "juandebravo"
    #
    #      set_channels!(message) => message.channel_name = ["twitter-channel-1"]
    #
    # ==== Parameters
    # * +message+ Connfu::Message with no channel_name info
    # ==== Return
    # * Connfu::Message with the channel_name filled with the relevant app channels
    def set_channels!(message) # :doc:
      channel_type = message.channel_type

      # select channels with the same channel_type as the incoming message
      channels = @app_channels.select { |channel| channel["type"].eql?(channel_type) }

      # filter channels
      case message.channel_type
        when "twitter"  # filter by from or to account
          channels = channels.select { |channel| 
            channel["accounts"].select { |item| 
              item["name"].eql?(message.from) or item["name"].eql?(message.to)
            }.length > 0 
          }
        when "voice" # filter by did
          channels = channels.select { |channel| 
            channel["uid"].eql?(message.channel_name)
            #channel["phones"].select{|item| 
            #  item["phone_number"].eql?(message.to)
            #}.length > 0 
          }
        when "sms"
          channels = channels.select { |channel| 
            channel["phones"].select{|item| 
              item["phone_number"].eql?(message.to)
            }.length > 0 
          }
        when "rss"
          channels = channels.select { |channel| 
            channel["uri"].eql?(message.channel_name)
          }
        else
          logger.warn("This code should not be executed because the first select should avoid this")
          logger.info("Unexpected message: #{message.channel_type}")
          channels = []
      end

      # get only the channel unique identifier
      channels = channels.map { |channel| channel["uid"] }

      logger.debug "Setting channels in the incoming message to #{channels}"
      message.channel_name = channels
    end

    # Executes the blocks that are associated to that channel and event type
    # @param *message* incoming message to be processed
    def process_message(message)
      logger.info("Calling event #{message.message_type} in the channel #{message.channel_type}")
      @listener_channels[message.channel_type.to_sym].message(message.message_type.to_sym, message)
    end

  end

end