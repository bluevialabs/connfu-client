$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')

require 'connfu'

##
# This application is an example of how to create a connFu application

token = ARGV.shift

Connfu.logger = STDOUT
Connfu.log_level = Logger::DEBUG

Connfu.application(token) {

    listen(:sms) do |sms|
          sms.on(:new) do |message|
              puts "New inbound sms from #{message[:from]}: #{message[:content]}"
          end
    end


}