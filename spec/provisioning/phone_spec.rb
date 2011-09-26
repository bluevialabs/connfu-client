#
# connFu is a platform of Telefonica delivered by Bluevia Labs
# Please, check out www.connfu.com and if you need more information
# contact us at mailto:support@connfu.com
#

require 'connfu'

require 'spec_helper'

describe Connfu::Provisioning::Phone do

  before(:each) do
    @phone = Connfu::Provisioning::Phone.new(VOICE_KEY, PHONE_NUMBER, COUNTRY)
  end
  
  # Matcher that helps to test if an Application instance is well defined after retrieving data using prov API
  RSpec::Matchers.define :be_well_defined_as_phone do |voice_key, phone_number, country|
    match do |phone|
      phone.should be_instance_of(Connfu::Provisioning::Phone)
      phone.voice.should eql(voice_key)
      phone.phone_number.should eql(phone_number)
      phone.country.should eql(country)
    end
  end

  context "while initializing" do
    it "should set properly the instance attributes" do
      @phone.should be_well_defined_as_phone(VOICE_KEY, PHONE_NUMBER, COUNTRY)
    end

    it "should retrieve the country instance variable using the [] method" do
      @phone[:country].should eql(COUNTRY)
    end

    it "should retrieve the phone_number instance variable using the [] method" do
      @phone[:phone_number].should eql(PHONE_NUMBER)
    end

    it "should retrieve the voice instance variable using the [] method" do
      @phone[:voice].should eql(VOICE_KEY)
    end

    it "should retrieve nil using the [] method when the instance variable does not exists" do
      @phone[:foo].should be_nil
    end
  end

  context "while hashing" do
    it "should include the country and phone_number" do
      phone_hash = @phone.to_hash
      phone_hash.should be_instance_of(Hash)
      ["country", "phone_number"].each{|key|
        phone_hash.should have_key(key)
      }
    end

    it "should include the valid country value" do
      phone_hash = @phone.to_hash
      phone_hash["country"].should eql(COUNTRY)
    end

    it "should include the valid phone_number value" do
      phone_hash = @phone.to_hash
      phone_hash["phone_number"].should eql(PHONE_NUMBER)
    end
  end
  
  context "while unmarshaling" do
    let(:raw) {
      {"phone_number" => PHONE_NUMBER, "country" => COUNTRY}
    }
    
    it "should unmarshal successfully a single phone data" do
      value = Connfu::Provisioning::Phone.unmarshal(VOICE_KEY, raw)
      value.should be_well_defined_as_phone(VOICE_KEY, PHONE_NUMBER, COUNTRY)
    end

    it "should unmarshal successfully a raw data with two phones" do
      values = Connfu::Provisioning::Phone.unmarshal(VOICE_KEY, [raw, raw])
      values.each{|value|
        value.should be_well_defined_as_phone(VOICE_KEY, PHONE_NUMBER, COUNTRY)
      }
    end
  end
  

end
