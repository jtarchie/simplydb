$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rack/test'
require 'rspec'
require 'webmock/rspec'
require 'vcr'
require 'timecop'
require 'simplydb'

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f}

Rspec.configure do |config|
  def access_key
    '12345'
  end
  
  def secret_key
    '67890'
  end

    def vcr_record_option
      :none
    end

  config.extend VCR::RSpec::Macros

  config.before do
    Timecop.freeze Time.local(2011,4,11, 23, 9)
  end

  config.after do
    Timecop.return
  end
end