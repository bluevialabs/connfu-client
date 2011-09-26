$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'lib')

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', '..')

require 'connfu'

require 'examples/provisioning/setup'

ARGV.length < 4 and
(
  puts "Please include as argument the api_key, channel, whitelist name and whitelist number to be used"
  exit
)

api_key = ARGV.shift
channel_name = ARGV.shift

application = Connfu::Provisioning::Application.new(api_key, CONNFU_ENDPOINT)

begin
  puts application.add_whitelist(channel_name, ARGV.shift, ARGV.shift)
rescue Exception => ex
  puts "There was an error:"
  puts "Exception message: #{ex.inspect}"
end

