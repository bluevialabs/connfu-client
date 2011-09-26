$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'lib')

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', '..')

require 'connfu'

require 'examples/provisioning/setup'

ARGV.length < 2 and
(
  puts "Please include as argument the api_key and the channel to retrieve the whitelist"
  exit
)

api_key = ARGV.shift

channel = ARGV.shift

number = if ARGV.length < 1
                ""
              else
                ARGV.shift
              end



application = Connfu::Provisioning::Application.new(api_key, CONNFU_ENDPOINT)

begin
  puts application.get_whitelist(channel, number)
rescue Exception => ex
  puts "There was an error:"
  puts "Exception message: #{ex.message}"
  puts ex.backtrace
end

