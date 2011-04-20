require 'nokogiri'
require 'simplydb/error'

module SimplyDB
  class Interface
    attr_accessor :options, :client, :request_id, :box_usage, :next_token, :on_error
    def initialize(options = {})
      @options = {}.merge(options)
      @client = SimplyDB::Client.new(options)
    end

    def create_domain(name)
      call({'Action' => 'CreateDomain', 'DomainName' => name}) do |doc|
        doc.css("CreateDomainResponse").length > 0
      end
    end

    def delete_domain(name)
      call({'Action' => 'DeleteDomain', 'DomainName' => name}) do |doc|
        doc.css("DeleteDomainResponse").length > 0
      end
    end

    def list_domains
      call({'Action' => 'ListDomains'}) do |doc|
        doc.css('DomainName').collect{|d| d.text}
      end
    end

    def domain_metadata(name)
      call({'Action' => 'DomainMetadata','DomainName' => name}) do |doc|
        doc.css("DomainMetadataResult").first.children.inject({}) do |memo, child|
          memo[child.name] = child.text
          memo
        end
      end
    end

    def put_attributes(name, id, attributes = {}, expected = {}, replace = false)
      params = define_attributes(attributes, expected, replace)
      params.merge!({
        'DomainName' => name,
        'ItemName' => id,
        'Action' => 'PutAttributes'
      })
      call(params) do |doc|
        doc.css("PutAttributesResponse").length > 0
      end
    end

    def batch_put_attributes(name, items = {})
      params = {'DomainName' => name, 'ActionName' => 'BatchPutAttributes'}
      items.keys.each_with_index do |key, i|
        params["Item.#{i}.ItemName"] = key
        items[key].inject(0) do |j, (name,value)|
          value = [value] unless value.is_a?(Array)
          value.each do |v|
            params["Item.#{i}.Attribute.#{j}.Name"] = name
            params["Item.#{i}.Attribute.#{j}.Value"] = value
            j+=1
          end
          j
        end
      end
      call(params) do |doc|
        doc.css("BatchPutAttributesResponse").length > 0
      end
    end

    def delete_attributes(name, id, attributes = {}, expected = {})
      params = define_attributes(attributes, expected)
      params.merge!({
        'DomainName' => name,
        'ItemName' => id,
        'Action' => 'DeleteAttributes'
      })
      call(params) do |doc|
        doc.css("DeleteAttributesResponse").length > 0
      end
    end

    def get_attributes(name, id, wanted_attributes = [], consistent_read = false)
      params = {
        'Action' => 'GetAttributes',
        'DomainName' => name,
        'ItemName' => id,
        'ConsistentRead' => consistent_read.to_s,
      }
      wanted_attributes.each_with_index {|name, index| params["AttributeName.#{index}"] = name}

      call(params) do |doc|
        doc.css("Attribute").inject({}) do |memo, attribute|
          name = attribute.css("Name").first.text
          value = attribute.css("Value").first.text
          if memo.has_key?(name)
            memo[name] = [memo[name]] unless memo[name].is_a?(Array)
            memo[name] << value
          else
            memo[name] = value
          end
          memo
        end
      end
    end

    def select(expression, consistent_read = false, next_token = nil)
      params = {
        'Action' => 'Select',
        'SelectExpression' => expression,
        'ConsistentRead' => consistent_read.to_s,
      }
      params['NextToken'] = next_token unless next_token.nil?
      call(params) do |doc|
        doc.css("SelectResponse SelectResult Item").collect do |element|
          item_name = element.css("Name").first.text
          item = element.css("Attribute").inject({'Item' => item_name}) do |attributes, attribute|
            attribute_name = attribute.css("Name").first.text
            attribute_value = attribute.css("Value").first.text
            if attributes.has_key?(attribute_name)
              attributes[attribute_name] = [attributes[attribute_name]] unless attributes[attribute_name].is_a?(Array)
              attributes[attribute_name] << attribute_value
            else
              attributes[attribute_name] = attribute_value
            end
            attributes
          end
        end
      end
    end

    private
      def define_attributes(attributes = {}, expected = {}, replace = false)
        params = {}
        attributes.sort.inject(0) do |index, (k,v)|
          v = [v] unless v.is_a?(Array)
          v.each do |value|
            params["Attribute.#{index}.Name"] = k
            params["Attribute.#{index}.Value"] = value
            params["Attribute.#{index}.Replace"] = "true" if replace
            index += 1
          end
          index
        end
        expected.sort.inject(0) {|index, (k,v)|
          case v
            when Array
              v.each do |value|
                params["Expected.#{index}.Name"] = k
                params["Expected.#{index}.Value"] = value
                index += 1
              end
            when :exists
              params["Expected.#{index}.Name"] = k
              params["Expected.#{index}.Exists"] = v
              index += 1
            else
              params["Expected.#{index}.Name"] = k
              params["Expected.#{index}.Value"] = v
              index += 1
          end
          index
        }
        params
      end

      def call(params = {}, attempts = 3, &block)
        @client.call(:post, params) do |body|
          begin
            doc = Nokogiri::XML(body)
            if error = doc.css("Response Errors Error").first
              raise SimplyDB::Errors.const_get(error.css("Code").first.content), error.css("Message").first.content
            else
              #gather some stats from the request
              @request_id = doc.css("RequestId").first.text
              @box_usage = doc.css("BoxUsage").first.text.to_f
              @next_token = doc.css("NextToken").first.text unless doc.css("NextToken").empty?
              block.call(doc)
            end
          rescue SimplyDB::Errors::ServiceUnavailable, RestClient::ServiceUnavailable => e
            if attempts > 0
              call(params, attempts - 1, &block)
            else
              raise
            end
          end
        end
      end
  end
end