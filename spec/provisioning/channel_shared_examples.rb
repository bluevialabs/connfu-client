
require 'spec_helper'

def current_time
  @current_time ||= Time.now
end

def channel_attrs
  @channel_attrs ||= {:created_at => "2011-08-26 11:55:10 +0300",
                       :updated_at => "2011-08-26 11:55:10 +0300"
                      }
end


shared_examples_for "Channel" do |channel, type|


  RSpec::Matchers.define :have_defined_channel_attributes do |expected|
    match do |channel|
      channel_attrs.keys.each { |attribute|
        channel.send(attribute).should eql(expected[attribute])
      }
      channel.type.should be_instance_of(String)
      channel.uid.should be_instance_of(String)
    end
  end
  

  describe "while creating a Channel instance" do
    it "should initialize properly the meaning attributes" do
      channel.should be_kind_of(Connfu::Provisioning::Channel)
      channel.should have_defined_channel_attributes channel_attrs
    end

  end

  describe "to_hash method" do
    RSpec::Matchers.define :have_channel_details do |uid|
      match do |actual|
        actual.should be_instance_of(Hash)
        actual.should have_key("uid")
        actual["uid"].should be_instance_of(String)
      end
    end

    it "should retrieve uid" do
      #channel = Connfu::Provisioning::Channel.new(channel_attrs)
      channel.to_hash.should have_channel_details(CHANNEL_KEY)
    end
  end
  
end