require 'simplecov'
SimpleCov.start

require 'connfu'

require 'json'
# Configuration

Connfu.logger = 'connfu.log'

# Server
ENDPOINT = "http://localhost:3000/v1"

# App
APP_NAME = "benyehuda"
API_KEY = "api-key"
APP_DESCRIPTION = "This is a connFu application"
APP_STREAM_NAME="connfu-stream-app-1"

# Channels

CHANNEL_KEY = "channel-uid"

# Twitter
TWITTER_KEY = "twitter-uid"

# Voice
VOICE_KEY = "voice-uid"
PHONE_NUMBER = "44542279538"
COUNTRY = "UK"

TOPIC = "This is a conference powered by connFu."
WELCOME_MESSAGE = "Welcome to the conference!"
REJECTED_MESSAGE = "You're not allowed to join the conference"

# RSS
RSS_KEY = "rss-uid"

# DSL

NEW_CALL_MESSAGE = "new call received"

HANG_MESSAGE = "has left the call"

# Helper to create the post message to create a twitter channel
def create_twitter_channel_request(accounts = [], channel_uid = TWITTER_KEY, filter = "")
  {'uid' => channel_uid,'accounts' => accounts.map{|account| {'name' => account}},'filter' => filter}.to_json
end



