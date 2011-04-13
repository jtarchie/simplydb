require 'openssl'
require 'digest/sha1'
require 'base64'
require 'rest_client'

module SimplyDB
  class Client
      attr_accessor :options, :http_client

      def initialize(options = {})
        @options = {
          :protocol => 'https://',
          :host => 'sdb.amazonaws.com',
          :port => 443,
          :path => "/",
          :signature_version => '2',
          :version => '2009-04-15',
          :signature_method => 'HmacSHA256',
        }.merge(options)
      end

      def base_url
        "#{@options[:protocol]}#{@options[:host]}:#{@options[:port]}#{@options[:path]}"
      end

      def string_to_sign(method, params)
        return "#{method.to_s.upcase}\n#{options[:host]}\n/\n" + escape_hash(params)
      end

      def generate_signature(method, params)
        Base64.encode64(
          OpenSSL::HMAC.digest(
            OpenSSL::Digest::Digest.new('sha256'),
            @options[:secret_key],
            string_to_sign(method, params)
          )
        ).chomp
      end

      def params_with_signature(method, params)
        params.merge!({
          'AWSAccessKeyId' => @options[:access_key],
          'SignatureVersion' => @options[:signature_version],
          'Timestamp' => Time.now.iso8601,
          'Version' => @options[:version],
          'SignatureMethod' => @options[:signature_method]
        })
        params['Signature'] = generate_signature(method, params)
        params
      end

      def call(method, params, &block)
        params = params_with_signature(method, params)
        response = case method.to_sym
#          when :get
#            RestClient.get(base_url << "?#{escape_hash(params)}")
          when :post
            RestClient.post(base_url, params)
          else
            raise "Not support request method #{method}"
                   end
        block.call(response.body)
      rescue RestClient::BadRequest => e
        block.call(e.response.body)
      end
      
      private
      
      def escape_value(string)
        string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
          '%' + $1.unpack('H2' * $1.size).join('%').upcase
        end.gsub(' ', '%20')
      end

      def escape_hash(params = {})
        return params.collect{|k,v| [k.to_s, v.to_s]}.sort.collect { |key, value| [escape_value(key), escape_value(value)].join('=') }.join('&')
      end
    end
end