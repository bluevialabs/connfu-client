$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', 'lib')

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')

require 'connfu'

require 'examples/provisioning/setup'

ARGV.length < 1 and
    (
    puts "Please include as argument the api_key"
    exit
    )

api_key = ARGV.shift

channel = if ARGV.length < 1
                ""
              else
                ARGV.shift
              end


application = Connfu::Provisioning::Application.new(api_key, CONNFU_ENDPOINT)

begin
  puts application.get_twitter_channel(channel)
rescue Exception => ex
  puts "There was an error:"
  puts "Exception message: #{ex.message}"
end

