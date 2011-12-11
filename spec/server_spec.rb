require File.dirname(__FILE__) + '/spec_helper'
require "json"

SimplyDB::Server.get('/raise_error') do
  raise SimplyDB::Errors::AccessFailure, "With explaination of why..."
end

describe SimplyDB::Server do
  include Rack::Test::Methods

  def sleep!
    sleep(5) if vcr_record_option == :new_episodes
  end

  let(:default_domains) {["rspec1", "rspec2", "rspec3", "rspec4"]}

  before do
    Timecop.freeze Time.local(2011, 4, 20, 3, 47)
  end
  
  before(:all) do
    Timecop.freeze Time.local(2011, 4, 20, 3, 47)

    VCR.use_cassette("create_env", :record => vcr_record_option) do

      default_domains.each do |domain|
        interface.create_domain(domain)
      end
      interface.put_attributes("rspec1", "testID", {"zip"=>"90210", "address"=>"123 Main St", "age"=>"27", "name"=>"John Smith", "state"=>"CA", "city"=>"San Francisco"}, {}, true)
      interface.put_attributes("rspec1", "updateID", {"zip"=>"90210", "address"=>"123 Main St", "age"=>"27", "name"=>"John Smith", "state"=>"CA", "city"=>"San Francisco"}, {}, true)
      interface.put_attributes("rspec1", "delete_partialID", {"zip"=>"90210", "address"=>"123 Main St", "age"=>"27", "name"=>"John Smith", "state"=>"CA", "city"=>"San Francisco"}, {}, true)
      interface.put_attributes("rspec1", "delete_allID", {"zip"=>"90210", "address"=>"123 Main St", "age"=>"27", "name"=>"John Smith", "state"=>"CA", "city"=>"San Francisco"}, {}, true)
    end
  end

  after(:all) do
    Timecop.freeze Time.local(2011, 4, 20, 3, 47)
    VCR.use_cassette("destroy_env", :record => vcr_record_option) do
      default_domains.each do |domain|
        interface.delete_domain(domain)
      end
    end
    Timecop.return
  end

  def app
    SimplyDB::Server.set :aws_secret_key, ENV['AWS_SECRET_KEY']
    SimplyDB::Server.set :aws_access_key, ENV['AWS_ACCESS_KEY']
    SimplyDB::Server.set :environment, :test
    SimplyDB::Server
  end

  def interface
    SimplyDB::Interface.new(
      :secret_key => 'UGoGs46IrIjnNSeskdysQ9QLnWRcO8SY1Lu2xdjU',
      :access_key => 'AKIAIYFIWGG2WUH6JIQA'
    )
  end
  
  shared_examples_for "successful JSON response" do
    it "returns successful" do
      last_response.status.should == 200
    end

    it "sets the content type for JSON" do
      last_response.content_type.should include "application/json"
    end

    it "should set the headers for request id, box usage, and next token" do
      last_response.headers['AMZ-BOX-USAGE'].should_not be_nil
      last_response.headers['AMZ-REQUEST-ID'].should_not be_nil
      last_response.headers['AMZ-NEXT-TOKEN'].should_not be_nil
    end
  end

  describe "domain operations" do

    describe "GET#domains" do
      use_vcr_cassette "get_domains", :record => vcr_record_option

      before do
        get '/domains'
      end

      it_behaves_like "successful JSON response"
      
      it "returns list of domains" do
        domains = JSON.parse(last_response.body)
        (domains & default_domains).should == default_domains
      end
    end

    describe "PUT#domains" do
      use_vcr_cassette "put_domains", :record => vcr_record_option

      before do
        put '/domains', {:name => 'rspec6'}
      end

      after do
        interface.delete_domain("rspec6")
      end

      it_behaves_like "successful JSON response"

      it "returns a list of current domains" do
        JSON.parse(last_response.body).should include("rspec6")
      end
    end

    describe "DELETE#domains" do
      use_vcr_cassette "delete_domains", :record => vcr_record_option

      before do
        interface.create_domain("rspec6")
        delete '/domains', {:name => 'rspec6'}
      end

      it_behaves_like "successful JSON response"

      it "returns a list of current domains" do
        JSON.parse(last_response.body).should_not include("rspec6")
      end
    end

    describe "GET#domains by name" do
      use_vcr_cassette "show_domains", :record => vcr_record_option

      before do
        get '/domains/rspec1'
      end

      it_behaves_like "successful JSON response"

      it "returns the meta data" do
        attributes = JSON.parse(last_response.body)
        attributes.delete("Timestamp")
        attributes.should == {"ItemCount"=>"4", "ItemNamesSizeBytes"=>"42", "AttributeNameCount"=>"6", "AttributeNamesSizeBytes"=>"26", "AttributeValueCount"=>"24", "AttributeValuesSizeBytes"=>"172"}
      end
    end
  end

  describe "items with a query" do
    use_vcr_cassette "query_items", :record => vcr_record_option
    before do
      get '/items', :q => 'SELECT * FROM rspec1 WHERE zip = "90210" LIMIT 2'
    end

    it_behaves_like "successful JSON response"

    it "returns an array of specific items base on the query" do
      JSON.parse(last_response.body).should == [
        {"address"=>"123 Main St", "name"=>"John Smith", "city"=>"San Francisco", "zip"=>"90210", "Item"=>"testID", "age"=>"27", "state"=>"CA"},
        {"address"=>"123 Main St", "name"=>"John Smith", "city"=>"San Francisco", "zip"=>"90210", "Item"=>"updateID", "age"=>"27", "state"=>"CA"}
      ]
    end
  end

  describe "item operations on a domain" do
    describe "GET#items by id" do
      use_vcr_cassette "get_items", :record => vcr_record_option

      before do
        get '/domains/rspec1/items/testID'
      end

      it_behaves_like "successful JSON response"

      it "returns list of the current attributes" do
        JSON.parse(last_response.body).should == {"zip"=>"90210", "address"=>"123 Main St", "age"=>"27", "name"=>"John Smith", "state"=>"CA", "city"=>"San Francisco"}
      end
    end

    describe "PUT#items by id" do
      use_vcr_cassette "put_items", :record => vcr_record_option

      before do
        put '/domains/rspec1/items/updateID', "item" => {"zip" => "12345", "age" => "28"}
        sleep!
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
      describe "with no query" do
        use_vcr_cassette "get_all_items", :record => vcr_record_option
        before do
          get '/domains/rspec1/items'
        end
      
        it_behaves_like "successful JSON response"

        it "returns an array of Item id with attributes" do
          JSON.parse(last_response.body).should == [
            {"Item"=>"testID", "zip"=>"90210", "address"=>"123 Main St", "name"=>"John Smith", "age"=>"27", "state"=>"CA", "city"=>"San Francisco"},
            {"Item"=>"updateID", "zip"=>"12345", "address"=>"123 Main St", "name"=>"John Smith", "age"=>"28", "state"=>"CA", "city"=>"San Francisco"},
            {"Item"=>"delete_partialID", "zip"=>"90210", "address"=>"123 Main St", "name"=>"John Smith", "age"=>"27", "state"=>"CA", "city"=>"San Francisco"},
            {"Item"=>"delete_allID", "zip"=>"90210", "address"=>"123 Main St", "name"=>"John Smith", "age"=>"27", "state"=>"CA", "city"=>"San Francisco"}
          ]
        end
      end

      pending "Should handle next token"
    end

    describe "DELETE#items by id" do
      context "delete certain attributes" do
        use_vcr_cassette "delete_items", :record => vcr_record_option

        before do
          delete '/domains/rspec1/items/delete_partialID', "item" => {"zip" => "90210", "age" => "27"}
          sleep!
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
        use_vcr_cassette "delete_items_all", :record => vcr_record_option

        before do
          delete '/domains/rspec1/items/delete_allID'
          sleep!
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
        last_response.status.should == SimplyDB::Errors::AccessFailure.new.http_status_code
      end
      
      it "should set a header with the supplied error message" do
        last_response.headers['AMZ-ERROR-TYPE'].should == "AccessFailure"
        last_response.headers['AMZ-ERROR-MESSAGE'].should == "With explaination of why..."
      end
    end
  end
end
