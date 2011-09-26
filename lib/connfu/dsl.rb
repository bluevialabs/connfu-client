require 'connfu/connfu_logger'

module Connfu
  ##
  # This class parses a connFu application defined using the DSL
  # i.e. 
  #
  #   Connfu.application(VALID_TOKEN, ENDPOINT) {
  #      listen(:voice) do |conference| {
  #         conference.on(:join) do |call|
  #           puts "New inbound call from #{call[:from]} on number #{call[:to]}"
  #         end
  #     }
  #      listen(:twitter) do |conference| {
  #        twitter.on(:new) do |tweet|
  #          puts "#{tweet[:channel_name]} just posted a new tweet: #{tweet.content}"
  #        end
  #     }
  #   }
  #
  module DSL
    include Connfu::ConnfuLogger
    
    class << self
      
      ##
      # Parses the given block
      # ==== Return
      #
      # Hash of values containing as key the listener channel type and as value the blocks to be executed
      # when an event associated to that channel is received
      def run
        @listener_channels = {}
        if block_given?
          self.instance_exec(&Proc.new)
          @listener_channels
        else
          nil
        end
      end
      
      ##
      # This method is called while parsing the application logic and a new channel is defined.
      # It inserts a new ListenerChannels in the listener_channels attribute with the Proc associated to
      # each event type.
      #
      # i.e.
      #      listen(:voice) do |conference| {
      #         conference.on(:join) do |call|
      #           puts "New inbound call from #{call[:from]} on number #{call[:to]}"
      #         end
      #     }
      #
      # While parsing this snippet of code, a new listener_channel will be stored, indicating that when
      # a new +join+ event associated to a +voice+ channel is received, the line 
      #
      #      puts "New inbound call from #{call[:from]} on number #{call[:to]}"
      #
      # must be executed.
      #
      # ==== Parameters
      #
      # * +name+ channel name
      # * +args+ actually not in used
      def listen(name, args = {})

        unless ListenerChannel.valid?(name)
          logger.error "Invalid channel name #{name}"
          return nil
        end

        # Create a new channel listener
        listener_channel = Connfu::ListenerChannel.new(name)

        # If defined, insert into the channel the desired logic
        block_given? and listener_channel.add_block(&Proc.new)

        # Add channel to channels array
        @listener_channels.store(name, listener_channel)
      end
      
    end
  end  
end