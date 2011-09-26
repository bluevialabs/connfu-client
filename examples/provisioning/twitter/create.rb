$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', 'lib')

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')

require 'connfu'

require 'examples/provisioning/setup'

ARGV.length < 4 and
(
  puts "Please include as argument the api_key, the channel name to be used, the kind of channel (origin, mentions) and the accounts"
  exit
)

api_key = ARGV.shift
channel_name = ARGV.shift
# should be either origin or mentions
type = ARGV.shift
users = ARGV

application = Connfu::Provisioning::Application.new(api_key, CONNFU_ENDPOINT)

hashtags = ["football", "tennis"]

begin
  puts application.create_twitter_channel(channel_name, {type.to_sym => users, :hashtags => hashtags})
rescue Exception => ex
  puts "There was an error: #{ex.inspect} "
  puts "Exception message: #{ex.backtrace}"
end

