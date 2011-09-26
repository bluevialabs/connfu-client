#
# connFu is a platform of Telefonica delivered by Bluevia Labs
# Please, check out www.connfu.com and if you need more information
# contact us at mailto:support@connfu.com
#


require 'spec_helper'

describe Connfu::ConnfuStream do
  
  let(:connfu_stream) do
    Connfu::ConnfuStream.new(APP_STREAM_NAME, API_KEY, ENDPOINT)
  end
  
  context "initialize" do
    it "should be an instance of Connfu::ConnfuStream when initialized" do
      connfu_stream.should be_an_instance_of(Connfu::ConnfuStream)
    end
    
    # Constructing RSpec examples programmatically
    {"app_stream" => APP_STREAM_NAME, "api_key" => API_KEY}.each do |attribute, value|
      it "should initialize properly the parameter #{attribute}" do
        connfu_stream.instance_variable_get("@#{attribute}").should eql(value)
      end
    end
    
    it "should define a custom message formatter" do
      connfu_stream.instance_variable_get("@formatter").should eql(Connfu::ConnfuMessageFormatter)
    end
  end
  
  context "queue" do
    let(:message) do
      Connfu::Message.new({})
    end
    
    it "should be an instance of Queue" do
      connfu_stream.send(:queue).should be_instance_of(Queue)
    end
    it "should be empty when intialized" do
      connfu_stream.send(:queue).empty?.should be_true
    end
    
    it "should be populate when an incoming message arrives" do
      connfu_stream.send(:message, [message])
      connfu_stream.send(:queue).empty?.should be_false
      connfu_stream.send(:queue).length.should be(1)
    end

    it "should be populate when several incoming message arrives" do
      connfu_stream.send(:message, [message, message, message])
      connfu_stream.send(:queue).empty?.should be_false
      connfu_stream.send(:queue).length.should be(3)
    end

    it "should retrieve the first message in the queue" do
      messages = [message, message, message]
      connfu_stream.send(:message, messages)
      connfu_stream.send(:queue).empty?.should be_false
      messages.each{|msg|
        connfu_stream.get.should eql(msg)
      }
    end

    it "should not add a message if it is not the valid type" do
      connfu_stream.send(:message, [1111])
      connfu_stream.send(:queue).empty?.should be_true
    end
    
  end
  
  context "authentication headers" do
    let(:headers) do
      {"accept" => "application/json",
       "authorization" => "Backchat #{API_KEY}",
       "Connection" => "Keep-Alive"}
    end
    
    it "should include the required headers" do
      connfu_stream.send(:headers).should eql(headers)
    end
  end
end
