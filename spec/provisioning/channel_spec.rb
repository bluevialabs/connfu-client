#
# connFu is a platform of Telefonica delivered by Bluevia Labs
# Please, check out www.connfu.com and if you need more information
# contact us at mailto:support@connfu.com
#

require 'spec_helper'
require 'provisioning/channel_shared_examples'


describe Connfu::Provisioning::Channel do
  it_should_behave_like "Channel", Connfu::Provisioning::Channel.new(channel_attrs.merge({"uid" => CHANNEL_KEY, "type" => ""}))
end
