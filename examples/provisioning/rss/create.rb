$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', 'lib')

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')

require 'connfu'

require 'examples/provisioning/setup'

ARGV.length < 3 and
(
  puts "Please include as argument the api_key, the channel name to be used and the RSS URL"
  exit
)

api_key = ARGV.shift
channel_name = ARGV.shift
uri = ARGV.shift

application = Connfu::Provisioning::Application.new(api_key, CONNFU_ENDPOINT)


begin
  puts application.create_rss_channel(channel_name, uri)
rescue Exception => ex
  puts "There was an error: #{ex.inspect} "
  puts "Exception message: #{ex.message}"
end

