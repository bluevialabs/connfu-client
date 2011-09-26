$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', 'lib')

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')

require 'connfu'

require 'examples/provisioning/setup'

ARGV.length < 3 and
(
  puts "Please include as argument the api_key, the channel and the new topic value to be used"
  exit
)

api_key = ARGV.shift
channel = ARGV.shift
topic = ARGV.shift


application = Connfu::Provisioning::Application.new(api_key, CONNFU_ENDPOINT)

begin
  puts application.update_voice_channel(channel, topic)

rescue Exception => ex
  puts "There was an error:"
  puts "Exception message: #{ex.message}"
end

