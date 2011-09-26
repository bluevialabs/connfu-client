#
# connFu is a platform of Telefonica delivered by Bluevia Labs
# Please, check out www.connfu.com and if you need more information
# contact us at mailto:support@connfu.com
#

require 'spec_helper'

describe Connfu::Dispatcher do

  let(:prov_client) {
    application = Connfu::Provisioning::Application.new(API_KEY, ENDPOINT)
    application.stub(:name) {APP_NAME}
    application.stub(:description) {APP_DESCRIPTION}
    application.stub(:stream_name) {APP_STREAM_NAME}

    obj = double 'prov_client'
    obj.stub(:get_info) { application }
    obj.stub(:get_channels) { [] }
    obj
  }

  context "initialize" do
    it "should be a Dispatch class instance" do
      obj = Connfu::Dispatcher.new(nil, {:foo => "bar"})
      obj.should be_instance_of(Connfu::Dispatcher)
    end

    it "should raise an exception if no listener channels are provided" do
      lambda { Connfu::Dispatcher.new(nil, nil) }.should raise_error(Exception, "Unable to dispatch events if no channel is defined")
    end
  end

  context "set_channels" do
    let(:app_channels) do
      [{"uid"=>"twitter", "type"=>"twitter", "accounts"=>[{"name"=>"juandebravo"}, {"name"=>"connfudev"}], "filter"=>""},
       {"uid"=>"juan-voice", "type"=>"sms", "phones" => [{"country"=>"UK", "phone_number"=>"9876"}]},
       {"uid"=>"juan-voice", "type"=>"voice", "phones" => [{"country"=>"UK", "phone_number"=>"9876"}]},
       {"uid"=>"channel-1312722260", "type"=>"twitter", "accounts"=>[{"name"=>"juandebravo"}, {"name"=>"finnstr"}], "filter"=>""}]
    end

    let(:message_details) do
      {"id" => "external_id", "content" => "foo, bar", "from" => "connfudev", "to" => "osuka", "message_type" => "new"}
    end

    let(:voice_message_details) do
      details = message_details
      details["channel_type"] = "voice"
      details["to"] = "1234"
      details["channel_name"] = "juan-voice"
      details
    end

    let(:sms_message_details) do
      details = message_details
      details["channel_type"] = "sms"
      details["to"] = "9876"
      details["channel_name"] = "juan-voice"
      details
    end

    let(:twitter_message_details) do
      details = message_details
      details["channel_type"] = "twitter"
      details
    end

    it "should retrieve only the twitter channels when a twitter message from is retrieved" do
      details = twitter_message_details
      details["to"] = "unknown"
      details["from"] = "connfudev"
      message = Connfu::Message.new(details)
      message.channel_name.should be_nil

      obj = Connfu::Dispatcher.new(nil, {:foo => "bar"}, app_channels)
      obj.send(:set_channels!, message)
      message.channel_name.should be_kind_of(Array)
      message.channel_name.length.should eql(1)
    end

    it "should retrieve only the twitter channels when a twitter message from is retrieved. return two channels" do
      details = twitter_message_details
      details["to"] = "unknown"
      details["from"] = "juandebravo"
      message = Connfu::Message.new(details)
      message.channel_name.should be_nil

      obj = Connfu::Dispatcher.new(nil, {:foo => "bar"}, app_channels)
      obj.send(:set_channels!, message)
      message.channel_name.should be_kind_of(Array)
      message.channel_name.length.should eql(2)
    end

    it "should retrieve only the twitter channels when a twitter message to is retrieved" do
      details = twitter_message_details
      details["to"] = "connfudev"
      details["from"] = "unknown"
      message = Connfu::Message.new(details)
      message.channel_name.should be_nil
      obj = Connfu::Dispatcher.new(nil, {:foo => "bar"}, app_channels)
      obj.send(:set_channels!, message)
      message.channel_name.should be_kind_of(Array)
      message.channel_name.length.should eql(1)
    end

    it "should retrieve only the twitter channels when a twitter message to is retrieved. return two channels" do
      details = twitter_message_details
      details["to"] = "juandebravo"
      details["from"] = "unknown"
      message = Connfu::Message.new(details)
      message.channel_name.should be_nil

      obj = Connfu::Dispatcher.new(nil, {:foo => "bar"}, app_channels)
      obj.send(:set_channels!, message)
      message.channel_name.should be_kind_of(Array)
      message.channel_name.length.should eql(2)
    end

    it "should retrieve only the voice channels when a voice message is retrieved" do
      message = Connfu::Message.new(voice_message_details)
      message.channel_name.should_not be_nil
      message.channel_name.should eql("juan-voice")

      obj = Connfu::Dispatcher.new(nil, {:foo => "bar"}, app_channels)
      obj.send(:set_channels!, message)
      message.channel_name.should be_kind_of(Array)
      message.channel_name.length.should eql(1)
    end

    it "should retrieve no voice channel when DID is not expected" do
      voice = voice_message_details
      voice["channel_name"] = "foo"
      message = Connfu::Message.new(voice)
      message.channel_name.should_not be_nil
      message.channel_name.should eql("foo")

      obj = Connfu::Dispatcher.new(nil, {:foo => "bar"}, app_channels)
      obj.send(:set_channels!, message)
      puts message.channel_name
      message.channel_name.should be_kind_of(Array)
      message.channel_name.length.should eql(0)
    end

    it "should retrieve no sms channel when DID is not expected" do
      sms = sms_message_details
      sms["to"] = "1234"
      message = Connfu::Message.new(sms)

      obj = Connfu::Dispatcher.new(nil, {:foo => "bar"}, app_channels)
      obj.send(:set_channels!, message)
      puts message.channel_name
      message.channel_name.should be_kind_of(Array)
      message.channel_name.length.should eql(0)
    end

    it "should retrieve only the sms channels when a sms message is retrieved" do
      message = Connfu::Message.new(sms_message_details)
      message.channel_name.should_not be_nil
      message.channel_name.should eql("juan-voice")

      obj = Connfu::Dispatcher.new(nil, {:foo => "bar"}, app_channels)
      
      obj.send(:set_channels!, message)
      message.channel_name.should be_kind_of(Array)
      message.channel_name.length.should eql(1)
      message.channel_name[0].should eql("juan-voice")
    end

    it "should retrieve no channel when unknown channel_type is retrieved" do
      message = Connfu::Message.new(message_details)
      obj = Connfu::Dispatcher.new(nil, {:foo => "bar"}, app_channels)
      obj.send(:set_channels!, message)
      message.channel_name.should be_kind_of(Array)
      message.channel_name.length.should eql(0)
    end

  end


  context "twitter stream" do

    before(:each) do

      Connfu.stub(:prov_client).and_return(prov_client)
      Connfu.should_receive(:prov_client).twice

      Connfu::Dispatcher.any_instance.stub(:max_messages).and_return(10)
      Connfu::Listener.any_instance.stub(:max_messages).and_return(10)
      Connfu::Provisioning::Application.any_instance.stub(:get_channels).and_return { [] }

      Connfu::ConnfuStream.any_instance.stub(:start_listening) { nil }

      @id = 0
      Connfu::ConnfuStream.any_instance.stub(:get) {
        @id+=1
        message = "{\"id\":\"#{@id}\",\"remoteId\":\"87872349432582144\",\"summary\":\"\",\"content\":\":foo =&gt; \\\"bar\\\"\",\"sender\":\"twitter://connfudev/\",\"recipients\":[],\"tags\":[],\"links\":[],\"attachments\":[],\"timeStamp\":\"2011-07-04T13:16:15.000Z\",\"isDeleted\":false,\"isPublic\":true,\"isArticle\":false}"
        Connfu::ConnfuMessageFormatter.send(:format_message, message) # private method
      }

      #Connfu.logger = STDOUT

      @connfu = Connfu.application(API_KEY) {
        listen(:twitter) do |channel|

          channel.filter = "text has #conference"

          channel.on(:new) do |tweet|
            # puts "A new tweet arrived"
          end

        end

      }

    end

    describe "dispatcher" do
      it "should be an instance of Connfu::Dispatcher when initialized" do
        @connfu.dispatcher.should be_an_instance_of(Connfu::Dispatcher)
      end
      it "should receive ten messages" do
        @connfu.dispatcher.counter.should eql(10)
      end
    end
  end

end
