VCR.config do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), '..', 'fixtures', 'vcr')
  c.stub_with :webmock
  c.default_cassette_options = {
    :match_requests_on => [:uri, :method, :body]
  }
end