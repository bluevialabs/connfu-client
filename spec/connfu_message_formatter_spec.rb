##
# connFu is a platform of Telefonica delivered by Bluevia Labs.
#
# Please, check out www.connfu.com and if you need further information
# contact us at mailto:support@connfu.com

require 'spec_helper'
require 'connfu'

describe Connfu::ConnfuMessageFormatter do

  context "initialize" do

    it "should format properly a SMS event" do
      message = Connfu::ConnfuMessageFormatter.format_voice_sms(["sms", { "appId" => "123456", "from" => "+34677001122", "to" => "+4475234444", "message" => "Hello connFu application!" }])
      message.should be_instance_of(Array)
      message.length.should be(1)
      message = message.pop
      message.message_type.should eql("new")
      message.channel_type.should eql("sms")
      message.channel_name.should eql("123456")
      message.to.should eql("+4475234444")
      message.from.should eql("+34677001122")
    end

    it "should format properly a join event" do
      message = Connfu::ConnfuMessageFormatter.format_voice_sms(["join", {"appId" => "123456","conferenceId" => "connfu://channel-99999#", "from" => "+34677001122", "to" => "+4475234444"}])
      message.should be_instance_of(Array)
      message.length.should be(1)
      message = message.pop

      message.message_type.should eql("join")
      message.channel_type.should eql("voice")
      message.channel_name.should eql("channel-99999")
      message.to.should eql("+4475234444")
      message.from.should eql("+34677001122")
    end

    it "should discard an invalid voice event type" do
      message = Connfu::ConnfuMessageFormatter.format_voice_sms(["join2", {"appId" => "123456","conferenceId" => "connfu://99999#", "from" => "+34677001122", "to" => "+4475234444"}])
      message.should be_instance_of(Array)
      puts message[0]
      message.length.should be(0)
    end

    it "should discard an invalid voice event message" do
      message = Connfu::ConnfuMessageFormatter.format_voice_sms(["join2"])
      message.should be_instance_of(Array)
      puts message[0]
      message.length.should be(0)
    end

    it "should format properly a twitter event" do
      raw = {"id" => "source:twitter/94cc51b0-e5e3-11e0-a5f3-12313b050905","occurred_at" => "2011-09-23T12:57:23.000Z","actor" => {"object_type" => "person","id" => "connfudev","display_name" => "connfudev","published" => "2011-07-03T11:02:39.000Z","image" => {"url" => "http://a3.twimg.com/profile_images/1424588002/ninja_normal.jpg"},"statuses_count" => 128,"profile_text_color" => "333333","geo_enabled" => true,"show_all_inline_media" => false,"protected" => false,"friends_count" => 1,"favourites_count" => 0,"description" => "","profile_image_url_https" => "https://si0.twimg.com/profile_images/1424588002/ninja_normal.jpg","profile_use_background_image" => true,"following" => nil,"follow_request_sent" => nil,"listed_count" => 0,"default_profile_image" => false,"profile_link_color" => "0084B4","profile_sidebar_border_color" => "C0DEED","profile_sidebar_fill_color" => "DDEEF6","profile_background_image_url_https" => "https://si0.twimg.com/images/themes/theme1/bg.png","default_profile" => true,"profile_background_tile" => false,"utc_offset" => 0,"lang" => "en","is_translator" => false,"notifications" => nil,"verified" => false,"profile_background_image_url" => "http://a0.twimg.com/images/themes/theme1/bg.png","contributors_enabled" => false,"time_zone" => "London","followers_count" => 0,"profile_background_color" => "C0DEED"},"verb" => "post","object" => {"object_type" => "note","id" => "117221019508424704","url" => "http://twitter.com/connfudev/status/117221019508424704","published" => "2011-07-03T11:02:39.000Z","content" => "yoooooosss","in_reply_to_status_id" => nil,"retweeted" => false,"entities" => {"urls" => [],"user_mentions" => []},"truncated" => false,"place" => nil,"retweet_count" => 0,"favorited" => false,"contributors" => nil},"target" => {"object_type" => "list","display_name" => "connfudev's Twitter Timeline","summary" => "connfudev's Twitter Timeline","image" => {"url" => "http://a3.twimg.com/profile_images/1424588002/ninja_normal.jpg"}},"title" => "yoooooosss","provider" => {"object_type" => "service","id" => "http://twitter.com","display_name" => "Twitter","url" => "http://twitter.com"},"backchat" => {"source" => "TWITTER","bare_uri" => "twitter://connfudev/","user_path" => ["twitter-listener"],"journal" => ["backchat.tracker.TwitterJValueProcessor"],"uuid" => "94cd1500-e5e3-11e0-a5f3-12313b050905","channels" => ["twitter://connfudev/"]}}
      message = Connfu::ConnfuMessageFormatter.format_message(raw)
      message.should be_instance_of(Array)
      message.length.should be(1)
      message = message.pop
      message.message_type.should eql("new")
      message.channel_type.should eql("twitter")
      message.channel_name.should eql("connfudev")
      message.to.should be_nil
      message.from.should eql("connfudev")
    end

    it "should discard a invalid twitter event because sender is invalid" do
      raw = "{\"id\":\"1111111\",\"remoteId\":\"87872349432582144\",\"summary\":\"\",\"content\":\":foo =&gt; \\\"bar\\\"\",\"sender\":\"\",\"recipients\":[],\"tags\":[],\"links\":[],\"attachments\":[],\"timeStamp\":\"2011-07-04T13:16:15.000Z\",\"isDeleted\":false,\"isPublic\":true,\"isArticle\":false}"
      message = Connfu::ConnfuMessageFormatter.format_message(raw)
      message.should be_instance_of(Array)
      message.length.should be(0)
    end

    it "should discard a invalid twitter event because message is not a Hash" do
      raw = ["foo", "bar"]
      message = Connfu::ConnfuMessageFormatter.format_message(raw)
      message.should be_instance_of(Array)
      message.length.should be(0)
    end

    it "should discard a invalid twitter event because recipient is invalid" do
      raw = "{\"id\":\"1111111\",\"remoteId\":\"87872349432582144\",\"summary\":\"\",\"content\":\":foo =&gt; \\\"bar\\\"\",\"sender\":\"twitter://connfudev/\",\"recipients\":[\"foo\"],\"tags\":[],\"links\":[],\"attachments\":[],\"timeStamp\":\"2011-07-04T13:16:15.000Z\",\"isDeleted\":false,\"isPublic\":true,\"isArticle\":false}"
      message = Connfu::ConnfuMessageFormatter.format_message(raw)
      message.should be_instance_of(Array)
      message.length.should be(0)
    end
  end

end
