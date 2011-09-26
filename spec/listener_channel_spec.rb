#
# connFu is a platform of Telefonica delivered by Bluevia Labs
# Please, check out www.connfu.com and if you need more information
# contact us at mailto:support@connfu.com
#

require 'spec_helper'
require 'connfu'

describe Connfu::ListenerChannel do

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

  context "channel types" do
    it "defines four supported channel types" do
      Connfu::ListenerChannel::CHANNEL_TYPES.length.should eql(4)
    end
  end

  context "listener channels" do
    before(:each) do
      Connfu.stub(:prov_client).and_return(prov_client)
      Connfu.should_receive(:prov_client).twice

      Connfu::Listener.any_instance.stub(:start) { true }
      Connfu::Listener.any_instance.stub(:join) { true }
      Connfu::Dispatcher.any_instance.stub(:join) { true }
      Connfu::Provisioning::Application.any_instance.stub(:get_channels).and_return { [] }
      Connfu::ConnfuStream.any_instance.stub(:start_listening) { nil }
    end


    it "unsupported channel is unconsidered" do

      connfu = Connfu.application(API_KEY) {
        listen(:foo) do
          on(:new) do |call|
            puts "foo bar"
          end
        end
        listen(:twitter) do
          on(:new) do |call|
            puts "foo bar"
          end
        end
      }

      connfu.listener_channels.length.should eql(1)
    end

    it "supports RSS channel" do
      connfu = Connfu.application(API_KEY) {
        listen(:rss) do
          on(:new) do |rss|
            puts "foo bar"
          end
        end
      }
      connfu.listener_channels.length.should eql(1)
    end

    it "supports sms channel" do
      connfu = Connfu.application(API_KEY) {
        listen(:sms) do
          on(:new) do |sms|
            puts "foo bar"
          end
        end
      }
      connfu.listener_channels.length.should eql(1)
    end

    it "supports twitter channel" do
      connfu = Connfu.application(API_KEY) {
        listen(:twitter) do
          on(:new) do |tweet|
            puts "foo bar"
          end
        end
      }
      connfu.listener_channels.length.should eql(1)
    end

    it "supports voice channel" do
      connfu = Connfu.application(API_KEY) {
        listen(:voice) do
          on(:new) do |call|
            puts "foo bar"
          end
        end
      }
      connfu.listener_channels.length.should eql(1)
    end


    it "supports more than one channel" do
      connfu = Connfu.application(API_KEY) {
        listen(:voice) do
          on(:new) do |call|
            puts "foo bar"
          end
        end

        listen(:rss) do
          on(:new) do |rss|
            puts "foo bar"
          end
        end
      }
      connfu.listener_channels.length.should eql(2)
    end

    it "raise an exception if no channel defined" do
      lambda { @connfu = Connfu.application(API_KEY) {
      } }.should raise_error(Exception)

    end

  end
end