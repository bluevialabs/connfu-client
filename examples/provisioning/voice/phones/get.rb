$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'lib')

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', '..')

require 'connfu'

require 'examples/provisioning/setup'

ARGV.length < 2 and
    (
    puts "Please include as argument the api_key, the channel and optionally the phone number"
    exit
    )

api_key = ARGV.shift

channel = ARGV.shift

number = if ARGV.length < 1
                ""
              else
                ARGV.shift
              end


Connfu.log_level = Logger::DEBUG

application = Connfu::Provisioning::Application.new(api_key, CONNFU_ENDPOINT)


begin
  phones = application.get_phones(channel, number)
  p phones
rescue Exception => ex
  puts "There was an error:"
  puts "Exception message: #{ex.message}"
end

