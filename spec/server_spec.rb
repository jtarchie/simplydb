require File.dirname(__FILE__) + '/spec_helper'
require "json"

SimplyDB::Server.get('/raise_error') do
  raise SimplyDB::AccessFailure, "With explaination of why..."
end

describe SimplyDB::Server do
  include Rack::Test::Methods

  let(:default_domains) {["activity", "location", "notification", "person"]}

  before do
    Timecop.freeze Time.local(2011, 4, 13, 1, 40)
  end
  
  before(:all) do
    Timecop.freeze Time.local(2011, 4, 13, 1, 40)

    VCR.use_cassette("create_env", :record => :none) do

      default_domains.each do |domain|
        interface.create_domain(domain)
      end
      interface.put_attributes("activity", "testID", {"zip"=>"90210", "address"=>"123 Main St", "age"=>"27", "name"=>"John Smith", "state"=>"CA", "city"=>"San Francisco"}, {}, true)
      interface.put_attributes("activity", "updateID", {"zip"=>"90210", "address"=>"123 Main St", "age"=>"27", "name"=>"John Smith", "state"=>"CA", "city"=>"San Francisco"}, {}, true)
      interface.put_attributes("activity", "delete_partialID", {"zip"=>"90210", "address"=>"123 Main St", "age"=>"27", "name"=>"John Smith", "state"=>"CA", "city"=>"San Francisco"}, {}, true)
      interface.put_attributes("activity", "delete_allID", {"zip"=>"90210", "address"=>"123 Main St", "age"=>"27", "name"=>"John Smith", "state"=>"CA", "city"=>"San Francisco"}, {}, true)
    end
  end

  after(:all) do
    Timecop.freeze Time.local(2011, 4, 13, 1, 40)
    VCR.use_cassette("destroy_env", :record => :none) do
      default_domains.each do |domain|
        interface.delete_domain(domain)
      end
    end
    Timecop.return
  end

  def app
    SimplyDB::Server.set :aws_secret_key, ENV['AWS_SECRET_KEY'] || 'thhyyt9ZU3bo0Q/ZOt9C0dD8MZzJS8AUvrE9/B82'
    SimplyDB::Server.set :aws_access_key, ENV['AWS_ACCESS_KEY'] || '1VRWH6Y8EA9RKV7NHSR2'
    SimplyDB::Server.set :environment, :test
    SimplyDB::Server
  end

  def interface
    SimplyDB::Interface.new(
      :secret_key => ENV['AWS_SECRET_KEY'] || 'thhyyt9ZU3bo0Q/ZOt9C0dD8MZzJS8AUvrE9/B82',
      :access_key => ENV['AWS_ACCESS_KEY'] || '1VRWH6Y8EA9RKV7NHSR2'
    )
  end
  
  shared_examples_for "successful JSON response" do
    it "returns successful" do
      last_response.status.should == 200
    end

    it "sets the content type for JSON" do
      last_response.content_type.should == "application/json"
    end
  end

  describe "domain operations" do

    describe "GET#domains" do
      use_vcr_cassette "get_domains", :record => :none

      before do
        get '/domains'
      end

      it_behaves_like "successful JSON response"
      
      it "returns list of domains" do
        JSON.parse(last_response.body).should == ["activity", "location", "notification", "person"]
      end
    end

    describe "PUT#domains" do
      use_vcr_cassette "put_domains", :record => :none

      before do
        put '/domains', {:name => 'information'}
      end

      after do
        interface.delete_domain("information")
      end

      it_behaves_like "successful JSON response"

      it "returns a list of current domains" do
        JSON.parse(last_response.body).should == ["activity", "information", "location", "notification", "person"]
      end
    end

    describe "DELETE#domains" do
      use_vcr_cassette "delete_domains", :record => :none

      before do
        interface.create_domain("information")
        delete '/domains', {:name => 'information'}
      end

      it_behaves_like "successful JSON response"

      it "returns a list of current domains" do
        JSON.parse(last_response.body).should == ["activity", "location", "notification", "person"]
      end
    end

    describe "GET#domains by name" do
      use_vcr_cassette "show_domains", :record => :none

      before do
        get '/domains/activity'
      end

      it_behaves_like "successful JSON response"

      it "returns the meta data" do
        attributes = JSON.parse(last_response.body)
        attributes.delete("Timestamp")
        attributes.should == {"ItemCount"=>"4", "ItemNamesSizeBytes"=>"42", "AttributeNameCount"=>"6", "AttributeNamesSizeBytes"=>"26", "AttributeValueCount"=>"24", "AttributeValuesSizeBytes"=>"172"}
      end
    end
  end

  describe "item operations" do
    describe "GET#items by id" do
      use_vcr_cassette "get_items", :record => :none

      before do
        get '/domains/activity/items/testID'
      end

      it_behaves_like "successful JSON response"

      it "returns list of the current attributes" do
        JSON.parse(last_response.body).should == {"zip"=>"90210", "address"=>"123 Main St", "age"=>"27", "name"=>"John Smith", "state"=>"CA", "city"=>"San Francisco"}
      end
    end

    describe "PUT#items by id" do
      use_vcr_cassette "put_items", :record => :none

      before do
        put '/domains/activity/items/updateID', "item" => {"zip" => "12345", "age" => "28"}
      end

      it_behaves_like "successful JSON response"

      it "returns an empty response" do
        last_response.body.should == ""
      end

      it "updates the attributes" do
        interface.get_attributes("activity", "updateID").should == {"zip"=>"12345", "address"=>"123 Main St", "age"=>"28", "name"=>"John Smith", "state"=>"CA", "city"=>"San Francisco"}
      end
    end

    describe "GET#items" do
      use_vcr_cassette "get_all_items", :record => :none
      before do
        get '/domains/activity/items'
      end
      
      it_behaves_like "successful JSON response"

      it "returns a hash of item id to attributes" do
        JSON.parse(last_response.body).should == [
          {"Item"=>"testID", "zip"=>"90210", "address"=>"123 Main St", "name"=>"John Smith", "age"=>"27", "state"=>"CA", "city"=>"San Francisco"},
          {"Item"=>"updateID", "zip"=>"12345", "address"=>"123 Main St", "name"=>"John Smith", "age"=>"28", "state"=>"CA", "city"=>"San Francisco"},
          {"Item"=>"delete_partialID", "zip"=>"90210", "address"=>"123 Main St", "name"=>"John Smith", "age"=>"27", "state"=>"CA", "city"=>"San Francisco"},
          {"Item"=>"delete_allID", "zip"=>"90210", "address"=>"123 Main St", "name"=>"John Smith", "age"=>"27", "state"=>"CA", "city"=>"San Francisco"}
        ]
      end
    end

    describe "DELETE#items by id" do
      context "delete certain attributes" do
        use_vcr_cassette "delete_items", :record => :none

        before do
          delete '/domains/activity/items/delete_partialID', "item" => {"zip" => "90210", "age" => "27"}
        end

        it_behaves_like "successful JSON response"

        it "returns an empty response" do
          last_response.body.should == ""
        end

        it "updates the attributes" do
          interface.get_attributes("activity", "delete_partialID").should == {"address"=>"123 Main St", "name"=>"John Smith", "state"=>"CA", "city"=>"San Francisco"}
        end
      end

      context "deletes the entire item" do
        use_vcr_cassette "delete_items_all", :record => :none

        before do
          delete '/domains/activity/items/delete_allID'
        end

        it_behaves_like "successful JSON response"

        it "returns an empty response" do
          last_response.body.should == ""
        end

        it "updates the attributes" do
          interface.get_attributes("activity", "delete_allID").should == {}
        end
      end
    end
    
    describe "when handling errors from SimplyDB::Error" do
      before do
        get '/raise_error'
      end
      
      it "should proxy the HTTP error code associated with the SimplyDB::Error" do
        last_response.status.should == SimplyDB::AccessFailure.http_status_code
      end
      
      it "should set a header with the supplied error message" do
        last_response.headers['AMZ-ERROR-TYPE'].should == "AccessFailure"
        last_response.headers['AMZ-ERROR-MESSAGE'].should == "With explaination of why..."
      end
    end
  end
end
