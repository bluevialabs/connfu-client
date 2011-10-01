#
# connFu is a platform of Telefonica delivered by Bluevia Labs
# Please, check out www.connfu.com and if you need more information
# contact us at mailto:support@connfu.com
#

require 'spec_helper'

require 'webmock/rspec'

describe Connfu::Provisioning do

  before(:each) do
    @application = Connfu::Provisioning::Application.new(API_KEY, ENDPOINT)
  end

  # Matcher that helps to test if a Voice channel is well defined after retrieving data using prov API
  RSpec::Matchers.define :be_well_defined_as_voice do |uid, phones|
    match do |actual| # actual should be the Connfu::Provisioning::Voice instance
      actual.should be_instance_of(Connfu::Provisioning::Voice)
      ["uid", "channel_type", "phones"].each { |key|
        actual.to_hash.should have_key(key)
      }
      actual.uid.should eql(uid)
      actual.channel_type.should eql("voice")
      
      actual.should respond_to("topic")
      actual.should respond_to("welcome_message")
      actual.should respond_to("rejected_message")
      actual.should respond_to("privacy")

      actual.phones.should be_instance_of(Array)
      actual.phones.length.should eql(phones.length)

      actual.phones.each_with_index { |phone, index|
        ["phone_number", "country"].each { |key|
          phone.should respond_to(key.to_sym)
        }
        phone.phone_number.should eql(phones[index][:phone_number])
        phone.country.should eql(phones[index][:country])
      }
    end
  end

  # Matcher that helps to test if a Twitter channel is well defined after retrieving data using prov API
  RSpec::Matchers.define :be_well_defined_as_twitter do |uid, twitter_accounts|
    match do |actual| # actual should be the Connfu::Provisioning::Twitter instance
      actual.should be_instance_of(Connfu::Provisioning::Twitter)
      ["uid", "channel_type", "accounts"].each { |key|
        actual.to_hash.should have_key(key)
      }

      actual.uid.should eql(uid)
      actual.channel_type.should eql("twitter")

      actual.accounts.should be_instance_of(Array)
      actual.accounts.length.should eql(twitter_accounts.length)

      actual.accounts.each_with_index { |account, index|
        account.should have_key("name")
        account["name"].should eql(twitter_accounts[index])
      }
    end
  end

  context "channels" do

    context "all channels" do
      it "should retrieve all the channels that owns an application" do
        stub_request(:get, "#{ENDPOINT}/channels/?").
            with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200, :body => '[{"accounts":[{"name":"juandebravo"},{"name":"connfudev"}],"created_at":"2011-07-26T22:13:06+03:00","filter":"","uid":"twitter","updated_at":"2011-08-07T13:07:57+03:00","user_id":"user_id","type":"twitter"},{"country":"uk","created_at":"2011-08-07T14:39:14+03:00","phone":"441111112222","topic":"conference","uid":"juan-voice","updated_at":"2011-08-07T14:41:25+03:00","user_id":"user_id","type":"voice"}]', :headers => {})

        channels = @application.get_channels
        channels.should be_instance_of(Array)
        channels.length.should eql(2)
        voice_channels = channels.select { |channel| channel.instance_of?(Connfu::Provisioning::Voice) }
        twitter_channels = channels.select { |channel| channel.instance_of?(Connfu::Provisioning::Twitter) }
        voice_channels.length.should eql(1)
        twitter_channels.length.should eql(1)
      end
    end

    context "twitter" do
      it "should create a Twitter channel application with one origin speficied as array" do
        stub_request(:post, "#{ENDPOINT}/channels/twitter").
            with(:body => create_twitter_channel_request(["juan"]), :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 201, :body => "", :headers => {:location => "#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}"})

        response = @application.create_twitter_channel(TWITTER_KEY, ["juan"])
        response.should eql("#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}")
      end

      it "should create a Twitter channel application with one origins speficied as hash (string)" do
        stub_request(:post, "#{ENDPOINT}/channels/twitter").
            with(:body => create_twitter_channel_request(["juan"]), :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 201, :body => "", :headers => {:location => "#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}"})

        response = @application.create_twitter_channel(TWITTER_KEY, {:origin => "juan"})
        response.should eql("#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}")
      end

      it "should create a Twitter channel application with one origins speficied as hash (array)" do
        stub_request(:post, "#{ENDPOINT}/channels/twitter").
            with(:body => create_twitter_channel_request(["juan"]), :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 201, :body => "", :headers => {:location => "#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}"})

        response = @application.create_twitter_channel(TWITTER_KEY, {:origin => ["juan"]})
        response.should eql("#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}")
      end

      it "should create a Twitter channel application with two origins speficied as Hash" do
        stub_request(:post, "#{ENDPOINT}/channels/twitter").
            with(:body => create_twitter_channel_request(["juan", "connfu"]), :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 201, :body => "", :headers => {:location => "#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}"})

        response = @application.create_twitter_channel(TWITTER_KEY, {:origin => ["juan", "connfu"]})
        response.should eql("#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}")
      end

      it "should create a Twitter channel application with two origins speficied as Array" do
        stub_request(:post, "#{ENDPOINT}/channels/twitter").
            with(:body => create_twitter_channel_request(["juan", "connfu"]), :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 201, :body => "", :headers => {:location => "#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}"})

        response = @application.create_twitter_channel(TWITTER_KEY, ["juan", "connfu"])
        response.should eql("#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}")
      end

      it "should create a Twitter channel application with one mention" do
        stub_request(:post, "#{ENDPOINT}/channels/twitter").
            with(:body => create_twitter_channel_request(["juan"], TWITTER_KEY, "(recipients:juan)"), :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 201, :body => "", :headers => {:location => "#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}"})

        response = @application.create_twitter_channel(TWITTER_KEY, {:mentions => ["juan"]})
        response.should be_kind_of(Array)
        response[0].should eql("#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}")
      end

      it "should retrieve a channel information when the channel exists" do
        stub_request(:get, "#{ENDPOINT}/channels/twitter/#{TWITTER_KEY}?").
            with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200, :body => "{'accounts':[{'name':'juandebravo'}],'created_at':'2011-09-06T05:33:39+00:00','filter':'','uid':'#{TWITTER_KEY}','updated_at':'2011-09-06T05:33:39+00:00'}", :headers => {})

        twitter = @application.get_twitter_channel(TWITTER_KEY)

        twitter.should be_well_defined_as_twitter(TWITTER_KEY, ['juandebravo'])
      end

      it "should retrieve a list of one channel information when app has only one twitter channel" do
        stub_request(:get, "#{ENDPOINT}/channels/twitter/?").
            with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200, :body => "[{'accounts':[{'name':'juandebravo'}],'created_at':'2011-09-06T05:33:39+00:00','filter':'','uid':'#{TWITTER_KEY}','updated_at':'2011-09-06T05:33:39+00:00'}]", :headers => {})

        twitters = @application.get_twitter_channel

        twitters.should be_instance_of(Array)
        twitters.length.should eql(1)
        twitters[0].should be_well_defined_as_twitter(TWITTER_KEY, ['juandebravo'])

      end

      it "should retrieve a list of twitter channels information" do
        stub_request(:get, "#{ENDPOINT}/channels/twitter/?").
            with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200, :body => "[{'accounts':[{'name':'juandebravo'}],'created_at':'2011-09-06T05:33:39+00:00','filter':'','uid':'#{TWITTER_KEY}-0','updated_at':'2011-09-06T05:33:39+00:00'},{'accounts':[{'name':'juandebravo'}],'created_at':'2011-09-06T05:33:39+00:00','filter':'','uid':'#{TWITTER_KEY}-1','updated_at':'2011-09-06T05:33:39+00:00'}]", :headers => {})

        twitters = @application.get_twitter_channel

        twitters.should be_instance_of(Array)
        twitters.length.should eql(2)
        twitters.each_with_index { |twitter, index|
          twitter.should be_well_defined_as_twitter("#{TWITTER_KEY}-#{index}", ['juandebravo'])
        }
      end

    end

    context "voice" do

      it "should create a Voice channel application with the default privacy attribute" do
        stub_request(:post, "#{ENDPOINT}/channels/voice").
            with(:body => "{\"uid\":\"#{VOICE_KEY}\",\"country\":\"de\",\"privacy\":\"whitelisted\"}", :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 201, :body => "", :headers => {:location => "#{ENDPOINT}/channels/voice/#{VOICE_KEY}"})

        response = @application.create_voice_channel(VOICE_KEY, "de")
        response.should eql("#{ENDPOINT}/channels/voice/#{VOICE_KEY}")
      end

      it "should create a Voice channel application with a privacy attribute (public)" do
        stub_request(:post, "#{ENDPOINT}/channels/voice").
            with(:body => "{\"uid\":\"#{VOICE_KEY}\",\"country\":\"de\",\"privacy\":\"public\"}", :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 201, :body => "", :headers => {:location => "#{ENDPOINT}/channels/voice/#{VOICE_KEY}"})

        response = @application.create_voice_channel(VOICE_KEY, "de", Connfu::Provisioning::Voice::Privacy::PUBLIC)
        response.should eql("#{ENDPOINT}/channels/voice/#{VOICE_KEY}")
      end

      it "should create a Voice channel application with a privacy attribute (whitelisted)" do
        stub_request(:post, "#{ENDPOINT}/channels/voice").
            with(:body => "{\"uid\":\"#{VOICE_KEY}\",\"country\":\"de\",\"privacy\":\"whitelisted\"}", :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 201, :body => "", :headers => {:location => "#{ENDPOINT}/channels/voice/#{VOICE_KEY}"})

        response = @application.create_voice_channel(VOICE_KEY, "de", Connfu::Provisioning::Voice::Privacy::WHITELIST)
        response.should eql("#{ENDPOINT}/channels/voice/#{VOICE_KEY}")
      end

      it "should retrieve a channel information when the channel exists" do
        stub_request(:get, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}?").
            with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200, :body => "{'created_at':'2011-08-25T14:16:44+03:00','rejected_message':'You are not allowed to join this conference','privacy':'whitelisted','topic':'hello_man','uid':'#{VOICE_KEY}','updated_at':'2011-08-25T15:10:12+03:00','welcome_message':'Welcome to connFu, you are going to join the conference','phones':[{'country':'#{COUNTRY}','phone_number':'#{PHONE_NUMBER}'}]}", :headers => {})

        voice = @application.get_voice_channel(VOICE_KEY)

        voice.should be_well_defined_as_voice(VOICE_KEY, [{:phone_number => PHONE_NUMBER, :country => COUNTRY}])
      end

      it "should retrieve a list of channels information" do
        stub_request(:get, "#{ENDPOINT}/channels/voice/?").
            with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200, :body => "[{'created_at':'2011-08-25T14:16:44+03:00','rejected_message':'You are not allowed to join this conference','topic':'hello_man','uid':'#{VOICE_KEY}-0','updated_at':'2011-08-25T15:10:12+03:00','welcome_message':'Welcome to connFu, you are going to join the conference','phones':[{'country':'#{COUNTRY}','phone_number':'#{PHONE_NUMBER}'}]}, {'created_at':'2011-08-25T14:16:44+03:00','rejected_message':'You are not allowed to join this conference','topic':'hello_man','uid':'#{VOICE_KEY}-1','updated_at':'2011-08-25T15:10:12+03:00','welcome_message':'Welcome to connFu, you are going to join the conference','phones':[{'country':'#{COUNTRY}','phone_number':'#{PHONE_NUMBER}'}]}]", :headers => {})

        voices = @application.get_voice_channel

        voices.should be_instance_of(Array)
        voices.length.should eql(2)
        voices.each_with_index { |voice, index|
          voice.should be_well_defined_as_voice("#{VOICE_KEY}-#{index}", [{:phone_number => PHONE_NUMBER, :country => COUNTRY}])
        }
      end

      it "should retrieve a list of one channel information when app has only one voice channel" do
        stub_request(:get, "#{ENDPOINT}/channels/voice/?").
            with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200, :body => "[{'created_at':'2011-08-25T14:16:44+03:00','rejected_message':'You are not allowed to join this conference','topic':'hello_man','uid':'#{VOICE_KEY}','updated_at':'2011-08-25T15:10:12+03:00','welcome_message':'Welcome to connFu, you are going to join the conference','phones':[{'country':'#{COUNTRY}','phone_number':'#{PHONE_NUMBER}'}]}]", :headers => {})

        voice = @application.get_voice_channel
        voice.should be_instance_of(Array)
        voice.length.should eql(1)
        voice = voice.pop
        voice.should be_well_defined_as_voice(VOICE_KEY, [{:phone_number => PHONE_NUMBER, :country => COUNTRY}])
      end

      it "should delete a channel when the channel exists" do
        stub_request(:delete, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}?").
            with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200, :body => "", :headers => {})

        response = @application.delete_voice_channel(VOICE_KEY)
        response.should eql("")

      end

      it "should update a topic in a Voice channel application" do
        stub_request(:put, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}").
            with(:body => '{"topic":"new-topic"}', :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200)

        response = @application.update_voice_channel(VOICE_KEY, "new-topic")
        response.should eql("")
      end

      it "should update a topic in a Voice channel application using a Hash parameter" do
        stub_request(:put, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}").
            with(:body => '{"topic":"new-topic"}', :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200)

        response = @application.update_voice_channel(VOICE_KEY, {"topic" => "new-topic"})
        response.should eql("")
      end

      it "should update a welcome_message in a Voice channel application" do
        stub_request(:put, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}").
            with(:body => '{"welcome_message":"new-welcome_message"}', :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200)

        response = @application.update_voice_channel(VOICE_KEY, {:welcome_message => "new-welcome_message"})
        response.should eql("")
      end

      it "should update a rejected_message in a Voice channel application" do
        stub_request(:put, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}").
            with(:body => '{"rejected_message":"new-rejected_message"}', :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200)

        response = @application.update_voice_channel(VOICE_KEY, {"rejected_message" => "new-rejected_message"})
        response.should eql("")
      end

      it "should update a topic, welcome_message and rejected_message in a Voice channel application" do
        stub_request(:put, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}").
            with(:body => '{"topic":"new-topic","welcome_message":"new-welcome_message","rejected_message":"new-rejected_message"}', :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200)

        response = @application.update_voice_channel(VOICE_KEY, {"topic" => "new-topic", "welcome_message" => "new-welcome_message", "rejected_message" => "new-rejected_message"})
        response.should eql("")
      end


      context "phone numbers" do

        it "should process a phone number list with one number" do
          stub_request(:get, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}/phones/?").
              with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
              to_return(:status => 200, :body => "[{'country':'#{COUNTRY}','phone_number':'#{PHONE_NUMBER}'}]", :headers => {})

          voice_numbers = @application.get_phones(VOICE_KEY)
          voice_numbers.should be_an_instance_of(Array)
          voice_numbers.length.should eql(1)
          voice_numbers.each { |voice_number|
            voice_number.should be_instance_of(Connfu::Provisioning::Phone)
            voice_number.country.should eql(COUNTRY)
            voice_number.phone_number.should eql(PHONE_NUMBER)
          }
        end

        it "should process a phone number list with two numbers" do
          stub_request(:get, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}/phones/?").
              with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
              to_return(:status => 200, :body => "[{'country':'#{COUNTRY}','phone_number':'#{PHONE_NUMBER}'},{'country':'#{COUNTRY}','phone_number':'#{PHONE_NUMBER}'}]", :headers => {})

          voice_numbers = @application.get_phones(VOICE_KEY)
          voice_numbers.should be_an_instance_of(Array)
          voice_numbers.length.should eql(2)
          voice_numbers.each { |voice_number|
            voice_number.should be_instance_of(Connfu::Provisioning::Phone)
            voice_number.country.should eql(COUNTRY)
            voice_number.phone_number.should eql(PHONE_NUMBER)
          }
        end

        it "should process an empty phone number list" do
          stub_request(:get, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}/phones/?").
              with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
              to_return(:status => 200, :body => "[]", :headers => {})

          voice_numbers = @application.get_phones(VOICE_KEY)
          voice_numbers.should be_an_instance_of(Array)
          voice_numbers.length.should eql(0)
        end

        it "should delete a phone number" do
          stub_request(:delete, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}/phones/#{PHONE_NUMBER}?").
              with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
              to_return(:status => 200, :body => "", :headers => {})

          response = @application.delete_phone(VOICE_KEY, PHONE_NUMBER)
          response.should eql("")

        end


      end

      context "whitelist" do
        it "should process a whitelist with one number" do
          stub_request(:get, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}/whitelisted/?").
              with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
              to_return(:status => 200, :body => '[{"name":"juan","phone":"972542279538"}]', :headers => {})

          whitelist = @application.get_whitelist(VOICE_KEY)
          whitelist.should be_an_instance_of(Connfu::Provisioning::Whitelist)
          whitelist.users.should be_an_instance_of(Array)
          whitelist.users.length.should eql(1)
          whitelist.users.each { |user|
            user.should be_instance_of(Connfu::Provisioning::WhitelistUser)
          }
          whitelist.users[0].name.should eql("juan")
          whitelist.users[0].phone.should eql("972542279538")
        end

        it "should process a whitelist with more than one number" do
          stub_request(:get, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}/whitelisted/?").
              with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
              to_return(:status => 200, :body => '[{"name":"juan","phone":"972542279538"},{"name":"juandebravo","phone":"972542279531"}]', :headers => {})

          whitelist = @application.get_whitelist(VOICE_KEY)
          whitelist.should be_an_instance_of(Connfu::Provisioning::Whitelist)
          whitelist.users.should be_an_instance_of(Array)
          whitelist.users.length.should eql(2)
          whitelist.each { |user|
            user.should be_instance_of(Connfu::Provisioning::WhitelistUser)
          }

        end

        it "should process a whitelist number" do
          stub_request(:get, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}/whitelisted/#{PHONE_NUMBER}?").
              with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
              to_return(:status => 200, :body => "{'name':'juan','phone':'#{PHONE_NUMBER}'}", :headers => {})

          whitelist_number = @application.get_whitelist(VOICE_KEY, PHONE_NUMBER)
          whitelist_number.should be_an_instance_of(Connfu::Provisioning::WhitelistUser)
          whitelist_number.name.should eql("juan")
          whitelist_number.phone.should eql(PHONE_NUMBER)
        end

        it "should delete a whitelist list" do
          stub_request(:delete, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}/whitelisted/?").
              with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
              to_return(:status => 200, :body => "", :headers => {})

          response = @application.delete_whitelist(VOICE_KEY)
          response.should eql("")

        end

        it "should delete a whitelist number" do
          stub_request(:delete, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}/whitelisted/#{PHONE_NUMBER}?").
              with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
              to_return(:status => 200, :body => "", :headers => {})

          response = @application.delete_whitelist(VOICE_KEY, PHONE_NUMBER)
          response.should eql("")

        end

        it "should create a whitelist number with 2 parameters (name, phone)" do

          stub_request(:post, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}/whitelisted").
              with(:body => "{\"name\":\"juan\",\"phone\":\"#{PHONE_NUMBER}\"}", :headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
              to_return(:status => 200, :body => "", :headers => {})

          response = @application.add_whitelist(VOICE_KEY, 'juan', PHONE_NUMBER)
          response.should eql("")

        end

        it "should create a whitelist number with 1 parameter (WhitelistUser)" do

          stub_request(:post, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}/whitelisted").
              with(:body => "{\"name\":\"juan\",\"phone\":\"#{PHONE_NUMBER}\"}", :headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
              to_return(:status => 200, :body => "", :headers => {})

          response = @application.add_whitelist(VOICE_KEY, Connfu::Provisioning::WhitelistUser.new('juan', PHONE_NUMBER))
          response.should eql("")

        end

        it "should update a whitelist number with 1 parameter (WhitelistUser)" do

          stub_request(:put, "#{ENDPOINT}/channels/voice/#{VOICE_KEY}/whitelisted/#{PHONE_NUMBER}").
              with(:body => "{\"name\":\"juanito\"}", :headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
              to_return(:status => 200, :body => "", :headers => {})

          response = @application.update_whitelist(VOICE_KEY, Connfu::Provisioning::WhitelistUser.new('juanito', PHONE_NUMBER))
          response.should eql("")

        end
      end
    end

    context "rss" do
      it "should create a RSS channel application" do
        stub_request(:post, "#{ENDPOINT}/channels/rss").
            with(:body => "{\"uid\":\"#{RSS_KEY}\",\"uri\":\"http://connfu.com/rss\"}", :headers => {'Accept'=>'application/json', 'Content-Type' => 'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 201, :body => "", :headers => {:location => "#{ENDPOINT}/channels/voice/#{RSS_KEY}"})

        response = @application.create_rss_channel(RSS_KEY, "http://connfu.com/rss")
        response.should eql("#{ENDPOINT}/channels/voice/#{RSS_KEY}")
      end

      it "should retrieve a RSS channel information when the channel exists" do
        stub_request(:get, "#{ENDPOINT}/channels/rss/#{RSS_KEY}?").
            with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200, :body => "{'created_at':'2011-07-17T20:57:01+03:00','uri':'http://connfu.com/rss','uid':#{RSS_KEY},'updated_at':'2011-07-17T20:57:01+03:00'}", :headers => {})

        rss = @application.get_rss_channel(RSS_KEY)
        rss.uid.should eql(RSS_KEY)
        rss.uri.should eql("http://connfu.com/rss")
      end

      it "should retrieve all the RSS channels information when no name provided as argument" do
        stub_request(:get, "#{ENDPOINT}/channels/rss/?").
            with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200, :body => "[{'created_at':'2011-07-17T20:57:01+03:00','uri':'http://connfu.com/rss','uid':#{RSS_KEY}-0,'updated_at':'2011-07-17T20:57:01+03:00'}, {'created_at':'2011-07-17T20:57:01+03:00','uri':'http://connfu.com/rss','uid':#{RSS_KEY}-1,'updated_at':'2011-07-17T20:57:01+03:00'}]", :headers => {})

        rss = @application.get_rss_channel

        rss.should be_instance_of(Array)
        rss.length.should eql(2)
        rss.each_with_index { |channel, index|
          channel.uid.should eql("#{RSS_KEY}-#{index}")
          channel.uri.should eql("http://connfu.com/rss")
        }

      end

      it "should delete a channel when the channel exists" do
        stub_request(:delete, "#{ENDPOINT}/channels/rss/#{RSS_KEY}?").
            with(:headers => {'Accept'=>'application/json', 'AUTH_TOKEN' => "#{API_KEY}"}).
            to_return(:status => 200, :body => "", :headers => {})

        response = @application.delete_rss_channel(RSS_KEY)
        response.should eql("")
      end
    end
  end

end
