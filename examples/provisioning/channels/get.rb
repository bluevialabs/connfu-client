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

application = Connfu::Provisioning::Application.new(api_key, CONNFU_ENDPOINT)

begin
  channels = application.get_channels

  #channels.each{|channel|
  #  puts "##########"
  #  puts channel.class
  #  puts "channel #{channel.uid}"
  #  puts channel
  #}

  puts channels.map { |channel| channel.to_hash }
rescue Exception => ex
  puts "There was an error:"
  puts "Exception message: #{ex.message}"
end

