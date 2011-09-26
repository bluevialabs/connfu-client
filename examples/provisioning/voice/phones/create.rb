$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'lib')

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', '..')

require 'connfu'

require 'examples/provisioning/setup'

ARGV.length < 2 and
(
  puts "Please include as argument the api_key and the channel name to be used"
  exit
)

api_key = ARGV.shift
channel_name = ARGV.shift

application = Connfu::Provisioning::Application.new(api_key, CONNFU_ENDPOINT)

begin
  puts application.add_phone(channel_name, "UK")
rescue Exception => ex
  puts "There was an error: #{ex.inspect}"
  puts "Exception message: #{ex.message}"
end

