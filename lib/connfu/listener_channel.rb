require 'connfu/connfu_logger'

module Connfu

  ##
  # This class models a specific connFu listener channel.
  # A connFu listener channel is the path to fetch events from your resources.
  # 
  # ==== Current supported channel types:
  # - +:voice+: inbound calls to a phone number mapped to the application
  # - +:sms+: inbound sms to a phone number mapped to the application
  # - +:twitter+: tweet messages that matches at least one of the rules defined by the application
  # - +:rss+: atom or rss feed
  class ListenerChannel
    include Connfu::ConnfuLogger # application logger

    # Constant that defines the supported channels
    CHANNEL_TYPES = [:voice, :twitter, :sms, :rss]
    CHANNEL_TYPES.freeze
    CHANNEL_TYPES.each { |channel| channel.freeze }

    # Constant that defines the supported channel events
    EVENT_TYPES = [:new, :join, :leave, :new_topic]
    EVENT_TYPES.freeze
    EVENT_TYPES.each { |event| event.freeze }

    # channel name (a CHANNELS item)
    attr_reader :name

    # blocks associated to the channel. Hash object (key = event_type, value = Proc)
    attr_accessor :blocks

    # how to filter inbound events from connFu
    attr_reader :_filter

    ##
    # Channel initializer
    #
    # ==== Parameters
    # * +name+ channel name (CHANNELS item)
    def initialize(name)
      @name = name
      # initialize an Struct that shall keep the event blocks. There is a specific key per each event type
      @blocks = Struct.new(*EVENT_TYPES).new(*Array.new(EVENT_TYPES.length){Array.new()})
    end

    ##
    # Method that defines a new event in a channel
    # ==== Parameters
    # * +event+ event type. Must be included in EVENT_TYPES
    #
    def on(event)
      EVENT_TYPES.include?(event) or (self.class.logger.error "Invalid event #{event}" and return)
      block_given? and @blocks[event] << Proc.new
    end

    ##
    # 
    def message(event, arg = nil)
      @blocks[event].each { |block|
        block.call(arg)
      }
    end

    def filter=(value)
      @_filter = value
      # TODO
      # connFu provisioning request
    end

    def filter
      @_filter
    end

    def add_block
      block_given? and self.instance_exec self, &Proc.new

      #
      # Avoid using instance_exec: we can directly call the Proc received
      # but we need to change the expectations regarding context "messages"
      # @connfu.listener_channels[:foo].should... => @connfu.should
      #
      #block_given? and Proc.new.call(self)
    end

    class << self
      ##
      # Checks if a channel name is valid
      # ==== Parameters
      # * +name+ channel name
      # ==== Return
      # true if the channel name if valid, false if not
      def valid?(name)
        CHANNEL_TYPES.include?(name)
      end
    end

  end

end
