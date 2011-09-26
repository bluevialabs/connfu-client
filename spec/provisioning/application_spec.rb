#
# connFu is a platform of Telefonica delivered by Bluevia Labs
# Please, check out www.connfu.com and if you need more information
# contact us at mailto:support@connfu.com
#

require 'connfu'

require 'spec_helper'

describe Connfu::Provisioning::Application do

  before(:each) do
    @application = Connfu::Provisioning::Application.new(API_KEY, ENDPOINT)
  end
  
  # Matcher that helps to test if an Application instance is well defined after retrieving data using prov API
  RSpec::Matchers.define :be_well_defined_as_app do |name, description, stream_name|
    match do |app| # app should be the Connfu::Provisioning::Application instance
      app.should be_instance_of(Connfu::Provisioning::Application)
      app.name.should eql(APP_NAME)
      app.description.should eql(APP_DESCRIPTION)
      app.stream_name.should eql(APP_STREAM_NAME)
    end
  end

  context "Application" do
    context "get_info" do
      it "should retrieve name, description and stream_name" do
        @application.base.should_receive(:get).once.and_return("{'description':'#{APP_DESCRIPTION}', 'name':'#{APP_NAME}', 'stream_name':'#{APP_STREAM_NAME}'}")
        app = @application.get_info
        app.should be_well_defined_as_app(APP_NAME, APP_DESCRIPTION, APP_STREAM_NAME)        
      end
    end
    
    describe "instance attributes" do
      # Constructing RSpec examples programmatically
      {"name" => APP_NAME, "description" => APP_DESCRIPTION, "stream_name" => APP_STREAM_NAME}.each do |attribute, value|
          it "should make a HTTP request to retrieve app #{attribute}" do
            @application.base.should_receive(:get).once.and_return("{'description':'#{APP_DESCRIPTION}', 'name':'#{APP_NAME}', 'stream_name':'#{APP_STREAM_NAME}'}")
            @application.send(attribute.to_sym).should eql(value)
            @application.should be_well_defined_as_app(APP_NAME, APP_DESCRIPTION, APP_STREAM_NAME)
          end
        end
      end
    end
end
