$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'lib')

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', '..')

require 'connfu'

require 'examples/provisioning/setup'

ARGV.length < 4 and
(
  puts "Please include as argument the api_key, the channel name, the tone and the message to be used"
  exit
)

api_key = ARGV.shift
channel_name = ARGV.shift
tone = ARGV.shift
message = ARGV.shift

application = Connfu::Provisioning::Application.new(api_key, CONNFU_ENDPOINT)

begin
  puts application.add_dtmf(channel_name, tone, message)
rescue Exception => ex
  puts "There was an error: #{ex.inspect}"
  puts "Exception message: #{ex.message}"
end

