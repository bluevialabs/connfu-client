#
# connFu is a platform of Telefonica delivered by Bluevia Labs
# Please, check out www.connfu.com and if you need more information
# contact us at mailto:support@connfu.com
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'examples')

require 'spec_helper'

# Conference application
require 'conference/conference_app'

describe Connfu::DSL do

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

    Connfu::Listener.any_instance.stub(:start) { true }
    Connfu::Listener.any_instance.stub(:join) { true }
    Connfu::Dispatcher.any_instance.stub(:join) { true }
    Connfu::ConnfuStream.any_instance.stub(:start_listening) { nil }
    Connfu::Provisioning::Application.any_instance.stub(:get_channels).and_return {[]}

    @connfu = Connfu.application(API_KEY) {

      listen(:voice) do |channel|
        channel.on(:new) do |call|
          puts "#{NEW_CALL_MESSAGE} on number #{call[:destination]}"
          conf = ConferenceApp::find_by_conference_number(call[:destination])
          if conf.is_allowed?(call[:origin])
            puts "whitelist number received"
          else
            puts "not whitelist number"
          end
        end

        channel.on(:leave) do |call|
          puts "#{call[:origin]} #{HANG_MESSAGE} #{call[:destination]}"
          ConferenceApp::find(call[:destination]).end(call[:origin])
        end

        channel.on(:foo) do
        end
      end

      listen(:twitter) do |channel|

        channel.filter = "text has #conference"

        channel.on(:new) do |tweet|
          puts "A new tweet arrived"
          conf = ConferenceApp::find_by_twitter_user(tweet[:origin])
          conf.wall.print("#{tweet[:origin]}: has tweeted #{tweet[:destination]}")
        end

      end

      listen(:foo) do |channel|
        channel.on(:new) do |message|
          puts "This is an unsupported channel"
        end
      end

    }

  end

  context "channels" do

    it "should have two channels defined" do
      @connfu.listener_channels.length.should eql(2)
    end

    it "should have the channels :voice and :twitter" do
      [:voice, :twitter].each { |channel|
        @connfu.listener_channels.keys.should include(channel)
      }
    end

    it "channel voice blocks length should be 4 (one per event :new, :join, :leave, :new_topic)" do
      @connfu.listener_channels[:voice].blocks.length.should eql(4)
    end

    it "channel voice should have one block defined in :new event" do
      @connfu.listener_channels[:voice].blocks[:new].length.should eql(1)
      @connfu.listener_channels[:voice].blocks[:leave].length.should eql(1)
    end

    it "channel voice should have one block defined in :hang event" do
      @connfu.listener_channels[:voice].blocks[:leave].length.should eql(1)
    end

    it "channel twitter should have one block defined in :new event" do
      @connfu.listener_channels[:twitter].blocks[:new].length.should eql(1)
    end

  end

  context "filters" do
    it "should defined propertly the channel filter" do
      @connfu.listener_channels[:twitter].filter.should eql("text has #conference")
    end

  end

  context "messages" do

    context "voice" do

      it "should execute the defined block when a :new event is raised" do
        @connfu.listener_channels[:voice].should_receive(:puts).with("#{NEW_CALL_MESSAGE} on number 222").once
        @connfu.listener_channels[:voice].should_receive(:puts).with("whitelist number received").once

        # throw event
        @connfu.listener_channels[:voice].message(:new, {:origin => "111", :destination => "222"})
      end

      it "should execute the defined block when a :hang event is raised" do
        @connfu.listener_channels[:voice].should_receive(:puts).with("111 #{HANG_MESSAGE} 222").once
        @connfu.listener_channels[:voice].message(:leave, {:origin => "111", :destination => "222"})
      end
    end

    context "twitter" do
      it "should execute the defined block when a :new event is raised" do
        # mock wall
        wall = Wall.new
        wall.should_receive(:puts).with("juandebravo: has tweeted My new tweet").once
        conference = Conference.new("twitter")
        conference.should_receive(:wall).and_return(wall)

        # mock conference
        ConferenceApp.should_receive(:find_by_twitter_user).with("juandebravo").and_return(conference)

        @connfu.listener_channels[:twitter].should_receive(:puts).with("A new tweet arrived").once

        # throw event
        @connfu.listener_channels[:twitter].message(:new, {:origin => "juandebravo", :destination => "My new tweet"})
      end
    end

  end

end
