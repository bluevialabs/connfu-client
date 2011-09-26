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
if ARGV.length.eql?(1)
  attributes = ARGV.shift
else
  if ARGV.length % 2 == 0
    # create a hash using array values: odd values => key, even values => value
    attributes = Hash[*ARGV]
  else
    puts "Invalid number of arguments"
    exit
  end
end

application = Connfu::Provisioning::Application.new(api_key, CONNFU_ENDPOINT)

begin
  puts application.update_voice_channel(channel, attributes)

rescue Exception => ex
  puts "There was an error:#{ex.inspect}"
  puts "Exception message: #{ex.message}"
end

