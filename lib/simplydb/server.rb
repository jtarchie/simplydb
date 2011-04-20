require "sinatra/base"
require "json"

module SimplyDB
  class Server < Sinatra::Base
    before /^\/(domains|items)/ do
      content_type :json
    end

    after /^\/(domains|items)/ do
      headers({
          'AMZ-BOX-USAGE' => interface.box_usage.to_s,
          'AMZ-REQUEST-ID' => interface.request_id.to_s,
          'AMZ-NEXT-TOKEN' => interface.next_token.to_s
      })
    end

    get '/domains' do
      interface.list_domains.sort.to_json
    end

    put '/domains' do
      interface.create_domain(params[:name])
      interface.list_domains.sort.to_json
    end

    delete '/domains' do
      interface.delete_domain(params[:name]).to_json
      interface.list_domains.sort.to_json
    end

    get '/domains/:name' do |name|
      interface.domain_metadata(name).to_json
    end

    get '/domains/:name/items/:item_id' do |name, item_id|
      attributes = interface.get_attributes(name, item_id)
      attributes.delete('Sdb-item-identifier')
      attributes.to_json
    end

    put '/domains/:name/items/:item_id' do |name, item_id|
      content_type :json
      interface.put_attributes(name, item_id, params[:item], {}, true)
      ""
    end

    delete '/domains/:name/items/:item_id' do |name, item_id|
      interface.delete_attributes(name, item_id, params[:item] || {}, {})
      ""
    end

    get '/domains/:name/items' do |name|
      interface.select("select * from #{name}").to_json
    end

    get '/items' do
      interface.select(params[:q] || params[:query]).to_json
    end
    
    error SimplyDB::Errors.constants.collect{|c| SimplyDB::Errors.const_get(c)} do
      content_type :json
      [
        env['sinatra.error'].http_status_code.to_i,
        {
          'AMZ-ERROR-TYPE' => env['sinatra.error'].name.sub('SimplyDB::Errors::', ''),
          'AMZ-ERROR-MESSAGE' => env['sinatra.error'].message
        },
        {
          'error' => {
            'type' => env['sinatra.error'].name,
            'message' => env['sinatra.error'].message
          }
        }.to_json
      ]
    end

    private

    def interface
      @interface ||= SimplyDB::Interface.new(
        :secret_key => settings.aws_secret_key,
        :access_key => settings.aws_access_key
      )
    end
  end
end