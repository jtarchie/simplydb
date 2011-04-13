require File.dirname(__FILE__) + '/spec_helper'

describe SimplyDB::Client do
  before do
    @client = SimplyDB::Client.new(
      :access_key => access_key,
      :secret_key => secret_key
    )
    @params = {
      'Action' => 'PutAttributes',
      'DomainName' => 'MyDomain',
      'ItemName' => 'Item123',
      'Attribute.1.Name' => 'Color',
      'Attribute.1.Value' => 'Blue',
      'Attribute.2.Name' => 'Size',
      'Attribute.2.Value' => 'Med',
      'Attribute.3.Name' => 'Price',
      'Attribute.3.Value' => '0014.99',
      'Version' => '2009-04-15',
      'Timestamp' => "2010-01-25T15:01:28-07:00",
      'SignatureVersion' => 2,
      'SignatureMethod' => 'HmacSHA256',
      'AWSAccessKeyId' => access_key
    }
    @query_string = "AWSAccessKeyId=#{access_key}&Action=PutAttributes&Attribute.1.Name=Color&Attribute.1.Value=Blue&Attribute.2.Name=Size&Attribute.2.Value=Med&Attribute.3.Name=Price&Attribute.3.Value=0014.99&DomainName=MyDomain&ItemName=Item123&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2010-01-25T15%3A01%3A28-07%3A00&Version=2009-04-15"
    @string_to_sign = "GET\nsdb.amazonaws.com\n/\n#{@query_string}"
    @post_body = '<PutAttributesResponse><ResponseMetadata><StatusCode>Success</StatusCode><RequestId>f6820318-9658-4a9d-89f8-b067c90904fc</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></PutAttributesResponse>'
  end
  
  it "should generate full URL" do
    @client.base_url.should == "https://sdb.amazonaws.com:443/"
  end
  
  it "should create the signed string for a POST" do
    #ie: http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/REST_RESTAuth.html
    @client.string_to_sign(:get, @params).should == @string_to_sign
  end
  
  it "should generate a correct signature" do
    @client.generate_signature(:get, @params).should == Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest::Digest.new('sha256'),
        secret_key,
        @string_to_sign
      )
    ).chomp
  end
  
  describe "#call" do
    it "should be able to make an HTTP POST request" do
      stub_request(:post, "https://sdb.amazonaws.com/").
              with(:body => 'Signature=1ds5YhHNymdgKTWOC0fjQ1YZlpBC%2FEh2K%2FbwE76auGI%3D&Version=2009-04-15&AWSAccessKeyId=12345&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&SignatureMethod=HmacSHA256&name=John').
              to_return(:status => 200, :body => "This example body.", :headers => {})
              @client.call(:post, {:name => "John"}) do |body|
                body.should == 'This example body.'
              end
    end
    
#    it "should be able to make an HTTP GET request" do
#      stub_request(:get, 'https://sdb.amazonaws.com/?AWSAccessKeyId=12345&Signature=jZawyzglv1f3CZJCC/zi+z33hsEc4zLidpT+JBy+5kw=&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2011-04-11T23:09:00-07:00&Version=2009-04-15&name=John').
#               to_return(:status => 200, :body => "This example body.", :headers => {})
#      @client.call(:get, {:name => "John"}) do |body|
#        body.should == 'This example body.'
#      end
#    end
  end
end