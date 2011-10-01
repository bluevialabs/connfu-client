#
# connFu is a platform of Telefonica delivered by Bluevia Labs
# Please, check out www.connfu.com and if you need more information
# contact us at mailto:support@connfu.com
#

require 'spec_helper'
require 'provisioning/channel_shared_examples'

describe Connfu::Provisioning::Voice do

  voice_attrs = channel_attrs.merge({:uid => VOICE_KEY,
           :topic => TOPIC,
           :welcome_message => WELCOME_MESSAGE,
           :rejected_message => REJECTED_MESSAGE})


  context "Voice" do

    let(:phone) do
      Connfu::Provisioning::Phone.new(VOICE_KEY, PHONE_NUMBER, COUNTRY)
    end
    
    RSpec::Matchers.define :have_defined_voice_attributes do |expected|
      match do |voice|
        [:uid, :topic, :welcome_message, :rejected_message].each { |attribute|
          voice.send(attribute).should eql(expected[attribute])
        }
        voice.channel_type.should eql("voice")
      end
    end
    
    it_should_behave_like "Channel", Connfu::Provisioning::Voice.new(voice_attrs)
    
    describe "while creating a Voice instance" do
      it "should initialize properly the meaning attributes" do
        voice = Connfu::Provisioning::Voice.new(voice_attrs)

        voice.should be_instance_of(Connfu::Provisioning::Voice)
        voice.should have_defined_voice_attributes voice_attrs
      end

      it "should have an empty phones list" do
        voice = Connfu::Provisioning::Voice.new(voice_attrs)

        voice.phones.should be_instance_of(Array)
        voice.phones.length.should eql(0)
      end
      
    end

    describe "handling phones" do

      it "should be empty after initializing" do
        voice = Connfu::Provisioning::Voice.new(voice_attrs)
        voice.phones.should be_instance_of(Array)
        voice.phones.length.should eql(0)

      end

      it "should add a phone to the array phone list" do
        voice = Connfu::Provisioning::Voice.new(voice_attrs)

        voice.phones.push(phone)
        voice.phones.length.should eql(1)
        voice.phones[0].should be_instance_of(Connfu::Provisioning::Phone)
      end

      it "should add a phone to the array phone list using the << method" do
        voice = Connfu::Provisioning::Voice.new(voice_attrs)

        voice << phone
        voice.phones.length.should eql(1)
        voice.phones[0].should be_instance_of(Connfu::Provisioning::Phone)
      end
    end

    describe "to_hash method" do

      # Matcher that helps to test if a Voice channel is well defined after retrieving data using prov API
      RSpec::Matchers.define :have_voice_details do |uid, phones|
        match do |actual| # actual should be the Connfu::Provisioning::Voice instance
          actual.should be_instance_of(Hash)
          
          ["uid", "channel_type", "phones"].each{|key|
            actual.should have_key(key)
          }

          actual["uid"].should eql(uid)
          actual["channel_type"].should eql("voice")
          
          actual["phones"].should be_instance_of(Array)
          actual["phones"].length.should eql(phones.length)
          
          actual["phones"].each_with_index{|phone, index|
            phone.should be_instance_of(Hash)
            ["phone_number", "country"].each{|key|
              phone.should have_key(key)
            }
            phone["phone_number"].should eql(phones[index][:phone_number])
            phone["country"].should eql(phones[index][:country])
          }
        end
      end

      it "should retrieved uid, channel_type and phones attributes (empty phones)" do
        voice = Connfu::Provisioning::Voice.new(voice_attrs)
        voice.to_hash.should have_voice_details(VOICE_KEY, [])
      end

      it "should retrieved uid, channel_type and phones attributes (phones with elements)" do
        voice = Connfu::Provisioning::Voice.new(voice_attrs)
        voice << phone
        voice.to_hash.should have_voice_details(VOICE_KEY, [phone])
      end

      it "should retrieved uid, channel_type and phones attributes (phones two elements)" do
        voice = Connfu::Provisioning::Voice.new(voice_attrs)
        voice << phone
        voice << phone
        voice.to_hash.should have_voice_details(VOICE_KEY, [phone, phone])
      end

      it "should retrieved uid, channel_type and phones attributes (phones hundred elements)" do
        voice = Connfu::Provisioning::Voice.new(voice_attrs)
        data = []
        100.times do
          voice << phone
          data << phone
        end
        voice.to_hash.should have_voice_details(VOICE_KEY, data)
      end

    end
  end


end
