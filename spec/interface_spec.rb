require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SimplyDB::Interface do
  before do
    @interface = SimplyDB::Interface.new(
      :access_key => access_key,
      :secret_key => secret_key
    )
  end

  describe "#define_attributes" do
    it "should define attributes" do
      @interface.send(:define_attributes, {'color'=>'red','size'=>'medium'}).should == {
        'Attribute.0.Name' => 'color',
        'Attribute.0.Value' => 'red',
        'Attribute.1.Name' => 'size',
        'Attribute.1.Value' => 'medium'
      }
    end

    it "should define attributes with arrays" do
      @interface.send(:define_attributes, {'color'=>['red','brick','garnet']}).should == {
        'Attribute.0.Name' => 'color',
        'Attribute.0.Value' => 'red',
        'Attribute.1.Name' => 'color',
        'Attribute.1.Value' => 'brick',
        'Attribute.2.Name' => 'color',
        'Attribute.2.Value' => 'garnet'
      }
    end

    it "should define attributes to be replaced" do
      @interface.send(:define_attributes, {'color'=>'red'}, {}, true).should == {
        'Attribute.0.Name' => 'color',
        'Attribute.0.Value' => 'red',
        'Attribute.0.Replace' => 'true',
      }
    end

    it "should define expected states of attributes" do
      @interface.send(:define_attributes, {}, {'quantity' => '0'}).should == {
        'Expected.0.Name' => 'quantity',
        'Expected.0.Value' => '0'
      }
    end
  end
  
  describe "successful API calls" do
    it "should set stats for a request" do
      stub_request(:post, "https://sdb.amazonaws.com/").
      with(:body => 'Action=DeleteDomain&Signature=Kt8H72qUjUZah09u9PB3BiRP8vgbfXQIa44bsJYofXo%3D&Version=2009-04-15&AWSAccessKeyId=12345&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&SignatureMethod=HmacSHA256&DomainName=MyDomain').
      to_return(:status => 200, :body => '<DeleteDomainResponse><ResponseMetadata><RequestId>c522638b-31a2-4d69-b376-8c5428744704</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></DeleteDomainResponse>')
      @interface.delete_domain('MyDomain')
      @interface.request_id.should == 'c522638b-31a2-4d69-b376-8c5428744704'
      @interface.box_usage.should == 0.0000219907
    end

    # http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_Operations.html
    describe "for attribute actions" do
      describe "#get_attributes" do
        it "should get attributes from an item" do
          stub_request(:post, "https://sdb.amazonaws.com/").
          with(:body => "Action=GetAttributes&Signature=5WfM4sn0VhO9e4CPp4ro6p94YvMLngh9m4GD0Ta0%2F7Y%3D&Version=2009-04-15&AWSAccessKeyId=12345&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&SignatureMethod=HmacSHA256&DomainName=MyDomain&ConsistentRead=false&ItemName=Item123").
          to_return(:status => 200, :body => '<GetAttributesResponse><GetAttributesResult><Attribute><Name>Color</Name><Value>Blue</Value></Attribute><Attribute><Name>Size</Name><Value>Med</Value></Attribute><Attribute><Name>Price</Name><Value>14</Value></Attribute></GetAttributesResult><ResponseMetadata><RequestId>b1e8f1f7-42e9-494c-ad09-2674e557526d</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></GetAttributesResponse>')
          @interface.get_attributes('MyDomain', 'Item123').should == {
            'Color' => 'Blue',
            'Size' => 'Med',
            'Price' => '14'
          }
        end

        it "should multiple values for an attribute" do
          stub_request(:post, "https://sdb.amazonaws.com/").
          with(:body => "Action=GetAttributes&Signature=5WfM4sn0VhO9e4CPp4ro6p94YvMLngh9m4GD0Ta0%2F7Y%3D&Version=2009-04-15&AWSAccessKeyId=12345&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&SignatureMethod=HmacSHA256&DomainName=MyDomain&ConsistentRead=false&ItemName=Item123").
          to_return(:status => 200, :body => '<GetAttributesResponse><GetAttributesResult><Attribute><Name>Color</Name><Value>Blue</Value></Attribute><Attribute><Name>Color</Name><Value>Red</Value></Attribute><Attribute><Name>Size</Name><Value>Med</Value></Attribute><Attribute><Name>Price</Name><Value>14</Value></Attribute></GetAttributesResult><ResponseMetadata><RequestId>b1e8f1f7-42e9-494c-ad09-2674e557526d</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></GetAttributesResponse>')
          @interface.get_attributes('MyDomain', 'Item123').should == {
            'Color' => ['Blue', 'Red'],
            'Size' => 'Med',
            'Price' => '14'
          }
        end

        it "should only get specific attributes" do
          stub_request(:post, "https://sdb.amazonaws.com/").
          with(:body => "Action=GetAttributes&Signature=%2BgO%2Fh7Ix7gkRO0u%2B9t%2BpOrQNldCslyItZm0EY%2F7Nz7g%3D&Version=2009-04-15&AWSAccessKeyId=12345&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&SignatureMethod=HmacSHA256&DomainName=MyDomain&AttributeName.0=Color&AttributeName.1=Size&ConsistentRead=false&ItemName=Item123").
          to_return(:status => 200, :body => '<GetAttributesResponse><GetAttributesResult><Attribute><Name>Color</Name><Value>Blue</Value></Attribute><Attribute><Name>Size</Name><Value>Med</Value></GetAttributesResult><ResponseMetadata><RequestId>b1e8f1f7-42e9-494c-ad09-2674e557526d</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></GetAttributesResponse>')
          @interface.get_attributes('MyDomain', 'Item123', ['Color','Size']).should == {
            'Color' => 'Blue',
            'Size' => 'Med'
          }
        end
      end

      it "should set a batch of attributes for items" do
        stub_request(:post, "https://sdb.amazonaws.com/").
        with(:body => 'Item.1.ItemName=Shirt2&Item.1.Attribute.0.Name=Size&Item.0.Attribute.2.Value[]=0014.99&Item.0.Attribute.0.Value[]=Med&Signature=xcmuW5MVl8JdSQIJOxCG5Z92555ickp9sM1TZFwgUk4%3D&Version=2009-04-15&Item.0.Attribute.1.Value[]=Blue&Item.0.Attribute.0.Name=Size&AWSAccessKeyId=12345&Item.1.Attribute.1.Value[]=Red&Item.0.ItemName=Shirt1&ActionName=BatchPutAttributes&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&Item.1.Attribute.2.Value[]=0019.99&SignatureMethod=HmacSHA256&Item.1.Attribute.2.Name=Price&Item.1.Attribute.1.Name=Color&Item.0.Attribute.2.Name=Price&Item.0.Attribute.1.Name=Color&DomainName=MyDomain&Item.1.Attribute.0.Value[]=Large').
        to_return(:status => 200, :body => '<BatchPutAttributesResponse><ResponseMetadata><RequestId>490206ce-8292-456c-a00f-61b335eb202b</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></BatchPutAttributesResponse>')
        @interface.batch_put_attributes('MyDomain',{
          'Shirt1' => {
            'Color' => 'Blue',
            'Size' => 'Med',
            'Price' => '0014.99'
          },
          'Shirt2' => {
            'Color' => 'Red',
            'Size' => 'Large',
            'Price' => '0019.99'
          }
        }) do |success|
          success.should == true
        end
        @interface.batch_put_attributes('MyDomain',{
          'Shirt1' => {
            'Color' => 'Blue',
            'Size' => 'Med',
            'Price' => '0014.99'
          },
          'Shirt2' => {
            'Color' => 'Red',
            'Size' => 'Large',
            'Price' => '0019.99'
          }
        }).should == true
      end

      it "should be able to perform a select query" do
        stub_request(:post, "https://sdb.amazonaws.com/").
        with(:body => 'Action=Select&Signature=o%2BGcUfU%2BGkNpiAuibSfNnMyYQ2zENrqqCtRcDRW9cZo%3D&Version=2009-04-15&AWSAccessKeyId=12345&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&SignatureMethod=HmacSHA256&SelectExpression=select%20Color%20from%20MyDomain%20where%20Color%20like%20\'Blue%25\'&ConsistentRead=false').
        to_return(:status => 200, :body => '<SelectResponse><SelectResult><Item><Name>Item_03</Name><Attribute><Name>Category</Name><Value>Clothes</Value></Attribute><Attribute><Name>Subcategory</Name><Value>Pants</Value></Attribute><Attribute><Name>Name</Name><Value>Sweatpants</Value></Attribute><Attribute><Name>Color</Name><Value>Blue</Value></Attribute><Attribute><Name>Color</Name><Value>Yellow</Value></Attribute><Attribute><Name>Color</Name><Value>Pink</Value></Attribute><Attribute><Name>Size</Name><Value>Large</Value></Attribute></Item><Item><Name>Item_06</Name><Attribute><Name>Category</Name><Value>Motorcycle Parts</Value></Attribute><Attribute><Name>Subcategory</Name><Value>Bodywork</Value></Attribute><Attribute><Name>Name</Name><Value>Fender Eliminator</Value></Attribute><Attribute><Name>Color</Name><Value>Blue</Value></Attribute><Attribute><Name>Make</Name><Value>Yamaha</Value></Attribute><Attribute><Name>Model</Name><Value>R1</Value></Attribute></Item></SelectResult><ResponseMetadata><RequestId>b1e8f1f7-42e9-494c-ad09-2674e557526d</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></SelectResponse>')
        @interface.select("select Color from MyDomain where Color like 'Blue%'").should == [
              {
                'Item_03' => {
                  'Category' => 'Clothes',
                  'Subcategory' => 'Pants',
                  'Name' => 'Sweatpants',
                  'Color' => ['Blue','Yellow','Pink'],
                  'Size' => 'Large'
                }
              },
              {
                'Item_06' => {
                  'Category' => 'Motorcycle Parts',
                  'Subcategory' => 'Bodywork',
                  'Name' => 'Fender Eliminator',
                  'Color' => 'Blue',
                  'Make' => 'Yamaha',
                  'Model' => 'R1'
                }
              }
            ]
      end

      it "should delete attributes from an item" do
        stub_request(:post, "https://sdb.amazonaws.com/").
        with(:body => "Action=DeleteAttributes&Signature=y0TiZtiCw43FcSq6gS6WzhEIgBELLm9zzX7dlNYlQn4%3D&Version=2009-04-15&AWSAccessKeyId=12345&Attribute.2.Value=garnet&Attribute.0.Value=red&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&Attribute.1.Value=brick&SignatureMethod=HmacSHA256&Attribute.2.Name=color&Attribute.1.Name=color&Attribute.0.Name=color&DomainName=MyDomain&ItemName=JumboFez").
        to_return(:status => 200, :body => '<DeleteAttributesResponse><ResponseMetadata><RequestId>05ae667c-cfac-41a8-ab37-a9c897c4c3ca</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></DeleteAttributesResponse>')
        @interface.delete_attributes('MyDomain', 'JumboFez', {'color'=>['red','brick','garnet']}).should == true
      end

      it "should be able to put attribues on an item" do
        stub_request(:post, "https://sdb.amazonaws.com/").
        with(:body => "Action=PutAttributes&Signature=mTCSIWRwZiOY%2BeXLMdp9962OCSwf6Z0slBzG2caFGBM%3D&Version=2009-04-15&AWSAccessKeyId=12345&Attribute.2.Value=garnet&Attribute.0.Value=red&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&Attribute.1.Value=brick&SignatureMethod=HmacSHA256&Attribute.2.Name=color&Attribute.1.Name=color&Attribute.0.Name=color&DomainName=MyDomain&ItemName=Item123").
        to_return(:status => 200, :body => '<PutAttributesResponse><ResponseMetadata><RequestId>490206ce-8292-456c-a00f-61b335eb202b</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></PutAttributesResponse>')
        @interface.put_attributes('MyDomain', 'Item123', {'color'=>['red','brick','garnet']}).should == true
      end
    end
    
    describe "for domain actions" do
      it "should be able to create a domain" do
        stub_request(:post, "https://sdb.amazonaws.com/").
        with(:body => "Action=CreateDomain&Signature=0Fwo7xWpFycQe1UHhGG4gXIZPPhtBLzTPRh7S4fzD%2BY%3D&Version=2009-04-15&AWSAccessKeyId=12345&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&SignatureMethod=HmacSHA256&DomainName=MyDomain").
        to_return(:status => 200, :body => '<CreateDomainResponse><ResponseMetadata><RequestId>2a1305a2-ed1c-43fc-b7c4-e6966b5e2727</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></CreateDomainResponse>')
        @interface.create_domain('MyDomain').should == true
      end

      it "should be able to delete a domain" do
        stub_request(:post, "https://sdb.amazonaws.com/").
        with(:body => "Action=DeleteDomain&Signature=Kt8H72qUjUZah09u9PB3BiRP8vgbfXQIa44bsJYofXo%3D&Version=2009-04-15&AWSAccessKeyId=12345&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&SignatureMethod=HmacSHA256&DomainName=MyDomain").
        to_return(:status => 200, :body => '<DeleteDomainResponse><ResponseMetadata><RequestId>c522638b-31a2-4d69-b376-8c5428744704</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></DeleteDomainResponse>')
        @interface.delete_domain('MyDomain').should == true
      end

      it "should be able to list domains" do
        stub_request(:post, "https://sdb.amazonaws.com/").
        with(:body => "Action=ListDomains&Signature=w2JjcUfj59tQ%2FmCyYPKDAviOaXg6WLP2Yt%2Ft9xeoTVw%3D&Version=2009-04-15&AWSAccessKeyId=12345&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&SignatureMethod=HmacSHA256").
        to_return(:status => 200, :body => '<ListDomainsResponse><ListDomainsResult><DomainName>Domain1-200706011651</DomainName><DomainName>Domain2-200706011652</DomainName><NextToken>TWV0ZXJpbmdUZXN0RG9tYWluMS0yMDA3MDYwMTE2NTY=</NextToken></ListDomainsResult><ResponseMetadata><RequestId>eb13162f-1b95-4511-8b12-489b86acfd28</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></ListDomainsResponse>')
        @interface.list_domains.should == ['Domain1-200706011651','Domain2-200706011652']
      end

      it "should be able to get the metadeta for a domain" do
        stub_request(:post, "https://sdb.amazonaws.com/").
        with(:body => "Action=DomainMetadata&Signature=ds9yJy3XI8FtUmk10LoqBs%2BqDCPAS%2FWpgjvtrWe%2BdYA%3D&Version=2009-04-15&AWSAccessKeyId=12345&SignatureVersion=2&Timestamp=2011-04-11T23%3A09%3A00-07%3A00&SignatureMethod=HmacSHA256&DomainName=Test").
        to_return(:status => 200, :body => '<DomainMetadataResponse xmlns="http://sdb.amazonaws.com/doc/2009-04-15/"><DomainMetadataResult><ItemCount>195078</ItemCount><ItemNamesSizeBytes>2586634</ItemNamesSizeBytes><AttributeNameCount >12</AttributeNameCount ><AttributeNamesSizeBytes>120</AttributeNamesSizeBytes><AttributeValueCount>3690416</AttributeValueCount><AttributeValuesSizeBytes>50149756</AttributeValuesSizeBytes><Timestamp>1225486466</Timestamp></DomainMetadataResult><ResponseMetadata><RequestId>b1e8f1f7-42e9-494c-ad09-2674e557526d</RequestId><BoxUsage>0.0000219907</BoxUsage></ResponseMetadata></DomainMetadataResponse>')
        @interface.domain_metadata('Test').should == {
            'ItemCount' => '195078',
            'ItemNamesSizeBytes' => '2586634',
            'AttributeNameCount' => '12',
            'AttributeNamesSizeBytes' => '120',
            'AttributeValueCount' => '3690416',
            'AttributeValuesSizeBytes' => '50149756',
            'Timestamp' => '1225486466'
          }
      end
    end
  end
end