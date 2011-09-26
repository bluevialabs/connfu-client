require 'active_support'
require 'connfu/connfu_logger'
require 'connfu/message'
require 'uri'

module Connfu

  ##
  # This class is in charge of formatting the incoming messages
  # It's used by any connFu listener to format a raw message got from the streaming API to a
  # Connfu::Message instance
  #
  class ConnfuMessageFormatter
    include Connfu::ConnfuLogger # application logger

    class << self

      ##
      # Convert an inbound twitter/RSS event to a Message instance.
      #
      # ==== Parameters
      #
      # * +message+ raw JSON decoded message
      # ==== Return
      # Array of Connfu::Message instances
      def format_message(message)
        message.is_a?(String) and message = ActiveSupport::JSON.decode(message)
        values = []

        # internal method that process the message
        fetch_values = lambda { |msg|
          begin
            if msg.is_a?(Hash)
              sender = msg["actor"]["id"]
              recipients = nil
              user_mentions = msg["object"]["entities"]["user_mentions"]
              logger.debug(user_mentions)
              if user_mentions.is_a?(Array) && user_mentions.length > 0
                recipients = []
                user_mentions.each { |recipient|
                  recipients << recipient
                }
                if recipients.length.eql?(1)
                  recipients = recipients[0]
                end
              end
              channel_info = msg["backchat"]["bare_uri"].split(":")
              logger.debug(channel_info)
              params = {
                  :id => msg["object"]["id"],
                  :content => msg["object"]["content"],
                  :message_type => "new",
                  :channel_type => channel_info[0],
                  :channel_name => channel_info[1][2..-2],
                  :from => sender,
                  :to => recipients
              }
              params
            else
              logger.error("Invalid message format: #{msg}")
              nil
            end
          rescue => ex
            logger.error("Unable to fetch values from message #{msg}. Caught exception #{ex}")
            nil
          end
        }

        if message.is_a?(Array)
          message.each { |msg|
            params = fetch_values.call(msg)
            # include the message if valid params
            params.nil? or values << Connfu::Message.new(params)
          }
        else
          params = fetch_values.call(message)
          # include the message if valid params
          params.nil? or values << Connfu::Message.new(params)
        end
        values
      end

      ##
      # Convert the inbound voice/sms event to a Message instance
      # ==== Parameters
      # * +message+ raw JSON decoded message
      #
      # ==== Return
      # * Array of one Connfu::Message instance
      # * Empty array if the message is invalid
      def format_voice_sms(message)
        if message.is_a?(Array) and message.length.eql?(2)
          if Connfu::Message.is_voice?(message[0])
            logger.debug("Format the new voice message")
            conference_id = URI.parse(message[1]["conferenceId"]).host
            params = {
                :id => 1234,
                :content => message[1]["newTopic"],
                :from => message[1]["from"],
                :to => message[1]["to"],
                :message_type => message[0],
                :channel_type => "voice",
                :channel_name => conference_id
            }
            logger.debug(params)

            [Connfu::Message.new(params)]
          elsif Connfu::Message.is_sms?(message[0])
            logger.debug("Format the new sms message")
            params = {
                :id => 1234,
                :content => message[1]["message"],
                :from => message[1]["from"],
                :to => message[1]["to"],
                :message_type => "new",
                :channel_type => "sms",
                :channel_name => message[1]["appId"]
            }
            [Connfu::Message.new(params)]
          else
            logger.error("Unexpected message type")
            logger.error(message)
            []
          end
        else
          logger.error("Unexpected message format")
          logger.error(message)
          []
        end
      end
    end

  end
end
