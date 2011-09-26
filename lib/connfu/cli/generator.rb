module Connfu
	##
	# This module helps a client to manage connFu applications
  module Cli
    module Generator
      
      APPLICATION_TEMPLATE=<<END

require 'connfu'

##
# This application is an example of how to create a connFu application

token = "YOUR-VALID-CONNFU-TOKEN"

Connfu.logger = STDOUT
Connfu.log_level = Logger::DEBUG

Connfu.application(token) {

    listen(:voice) do |conference|
        conference.on(:join) do |call|
                puts "New inbound call from \#{call[:from]} on number \#{call[:to]}"
            end

            conference.on(:leave) do |call|
                puts "\#{call[:from]} has left the conference \#{call[:channel_name]}"
            end

            conference.on(:new_topic) do |topic|
                puts "New topic in the conference \#{topic[:channel_name]}: \#{topic[:content]}"
            end
      end

      listen(:twitter) do |twitter|
            twitter.on(:new) do |tweet|
                puts "\#{tweet[:channel_name]} just posted a new tweet in the conference room: \#{tweet.content}"
            end
      end

      listen(:sms) do |sms|
            sms.on(:new) do |message|
                puts "New inbound sms from \#{message[:from]}: \#{message[:content]}"
            end
      end

}

END
      
      class << self
        ##
        #
        # ==== Parameters
        # * **name** application name
        # * **channels** channels the application should listen to
        # * **file_name** main file that will hold the application logic
        #
        # ==== Return
        def run(name, channels = nil, file_name = "application.rb")
          Dir.mkdir(name)
            Dir.chdir(name) do
            File.open(file_name, 'w') do |f|
              f.write(APPLICATION_TEMPLATE)
            end
          end
        end # end:run
      end # end class level
    end # end module Generator
  end # end module Cli
end