require "sinatra/base"
require "json"

module SimplyDB
  class Server < Sinatra::Base
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
      interface.put_attributes(name, item_id, params[:item], {}, true)
      ""
    end

    delete '/domains/:name/items/:item_id' do |name, item_id|
      interface.delete_attributes(name, item_id, params[:item] || {}, {})
      ""
    end

    get '/domains/:name/items' do |name|
      interface.select("select * from #{name}").each_value{|v| v.delete("Sdb-item-identifier")}.to_json
    end

    private

    def interface
      SimplyDB::Interface.new(
        :secret_key => settings.aws_secret_key,
        :access_key => settings.aws_access_key
      )
    end
  end
end