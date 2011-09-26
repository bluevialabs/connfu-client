#
# connFu is a platform of Telefonica delivered by Bluevia Labs
# Please, check out www.connfu.com and if you need more information
# contact us at mailto:support@connfu.com
#

require 'spec_helper'

describe Connfu do

  let(:prov_client) {
    application = Connfu::Provisioning::Application.new(API_KEY, "endpoint")
    application.stub(:name) {APP_NAME}
    application.stub(:description) {APP_DESCRIPTION}
    application.stub(:stream_name) {APP_STREAM_NAME}

    obj = double 'prov_client'
    obj.stub(:get_info) { application }
    obj.stub(:get_channels) {[]}
    obj
  }

  context "initialize" do

    before(:each) do

      Connfu.stub(:prov_client).and_return(prov_client)
      Connfu.should_receive(:prov_client).twice

      @connfu = Connfu.application(API_KEY)
    end

    it "should be an instance of Module when initialized" do
      @connfu.should be_an_instance_of(Module)
    end

    it "should initialize properly the token attribute" do
      @connfu.token.should eql(API_KEY)
    end

    it "should be able to read the token attribute" do
      @connfu.should respond_to(:token)
    end

    it "should not be able to write the token attribute" do
      lambda { @connfu.token="we5rwer" }.should raise_error (NoMethodError)
    end

  end

end
