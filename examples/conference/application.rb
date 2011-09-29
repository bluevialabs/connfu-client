$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '.')

# needed for 1.8.7, not needed in 1.9.2
RUBY_VERSION < "1.9.2" and require 'rubygems'
require 'connfu'

require 'conference'
require 'conference_app'
require 'wall'

#
# This application is an example of how to create a connFu application
# You should provide as parameter a valid TOKEN
#
# ruby application.rb VALID_TOKEN
# execute bundle install to download all the required gems
#

token = ARGV.shift

Connfu.logger = STDOUT

Connfu.log_level = Logger::DEBUG

@connfu = Connfu.application(token) {

  listen(:voice) do |conference|
    conference.on(:join) do |call|
      puts "New inbound call from #{call[:from]} on number #{call[:to]}"
      conf = ConferenceApp::find_by_conference_number(call[:destination])
      if conf.is_allowed?(call[:from])
        puts "whitelist number received"
      else
        puts "not whitelist number"
      end
    end

    conference.on(:leave) do |call|
      puts "Attendee left"
      puts "#{call[:from]} has left the conference #{call[:channel_name]}"
      ConferenceApp::find(call[:to]).end(call[:from])
    end

    conference.on(:new_topic) do |topic|
      puts "New topic in the conference #{topic[:channel_name]}: #{topic[:content]}"
    end
  end

  listen(:twitter) do |twitter|

    twitter.filter = "text has #conference"

    twitter.on(:new) do |tweet|
      puts "#{tweet[:from]} just posted a new tweet with content #{tweet.content} in the conference room: #{tweet[:channel_name]}"
      conf = ConferenceApp::find_by_twitter_user(tweet[:to])
      conf.wall.print("#{tweet[:from]} has tweeted => #{tweet[:content]}")
    end
  end

  listen(:rss) do |rss|
    rss.on(:new) do |post|
      puts "New post with title #{post[:content]} in the channel #{post[:channel_name]}"
    end
  end

  listen(:sms) do |sms|
    sms.on(:new) do |message|
      puts "New inbound sms"
      puts "#{message}"
    end
  end

}
