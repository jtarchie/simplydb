require File.dirname(__FILE__) + '/spec_helper'

describe SimplyDB::Error do
  before(:all) do
    class ExampleError < HTTPError(404); end
  end

  before do
    @error = ExampleError.new
  end

  it "contains the name of the error" do
    @error.name.should == "ExampleError"
  end

  it "contains a status code" do
    @error.http_status_code.should == 404
  end
  
  it "is an instance of RuntimeError" do
    @error.should be_kind_of(RuntimeError)
  end
end