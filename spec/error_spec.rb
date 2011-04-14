require File.dirname(__FILE__) + '/spec_helper'

describe SimplyDB::Error do
  before do
    @error = SimplyDB::Error.new("NotFound", 404)
  end

  it "contains the name of the error" do
    @error.name.should == "NotFound"
  end

  it "contains a status code" do
    @error.http_status_code.should == 404
  end
  
  it "is an instance of RuntimeError" do
    @error.should be_kind_of(RuntimeError)
  end
end