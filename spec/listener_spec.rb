#
# connFu is a platform of Telefonica delivered by Bluevia Labs
# Please, check out www.connfu.com and if you need more information
# contact us at mailto:support@connfu.com
#


require 'spec_helper'

describe Connfu::Listener do

  let(:prov_client) {
    application = Connfu::Provisioning::Application.new(API_KEY, ENDPOINT)
    application.stub(:name) {APP_NAME}
    application.stub(:description) {APP_DESCRIPTION}
    application.stub(:stream_name) {APP_STREAM_NAME}

    obj = double 'prov_client'
    obj.stub(:get_info) { application }
    obj.stub(:get_channels) {[]}
    obj
  }

  before(:each) do
    Connfu.stub(:prov_client).and_return(prov_client)
    Connfu.should_receive(:prov_client).twice

    Connfu::Dispatcher.any_instance.stub(:max_messages).and_return(10)
    Connfu::Listener.any_instance.stub(:max_messages).and_return(10)

    Connfu::ConnfuStream.any_instance.stub(:start_listening) { nil }

    @id = 0

    Connfu::Provisioning::Application.any_instance.stub(:get_channels).and_return {[]}

    Connfu::ConnfuStream.any_instance.stub(:get) {
      @id+=1
      message = "{\"id\":\"#{@id}\",\"remoteId\":\"87872349432582144\",\"summary\":\"\",\"content\":\":foo =&gt; \\\"bar\\\"\",\"sender\":\"twitter://connfudev/\",\"recipients\":[],\"tags\":[],\"links\":[],\"attachments\":[],\"timeStamp\":\"2011-07-04T13:16:15.000Z\",\"isDeleted\":false,\"isPublic\":true,\"isArticle\":false}"
      Connfu::ConnfuMessageFormatter.send(:format_message, message) # private method
    }

    @connfu = Connfu.application(API_KEY) {
      listen(:twitter) do |channel|
        channel.filter = "text has #conference"

        channel.on(:new) do |tweet|
          # puts "A new tweet arrived"
        end
      end

    }

  end

  context "twitter stream" do
    describe "listener" do
      it "should be an instance of Connfu::Listener when initialized" do
        @connfu.listener.should be_an_instance_of(Connfu::Listener)
      end
      it "should receive ten messages" do
        @connfu.listener.counter.should eql(10)
      end
    end
  end

end
