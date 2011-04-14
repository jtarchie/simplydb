= simplydb

A minimal interface to Amazon SimpleDB that has separation of interfaces. Build to support a Sinatra app that can be used as a JSON <-> SimpleDB proxy.

  require 'rubygems'
  require 'simplydb'

  interface = SimplyDB::Interface.new({
    :access_key => ENV['AWS_ACCESS_KEY'],
    :secret_key => ENV['AWS_SECRET_KEY']
  })

  if interface.create_domain("MyDomain")
    interface.put_attributes('MyDomain', 'Item123', {'color'=>['red','brick','garnet']})

    attributes = interface.get_attributes('MyDomain', 'Item123')
    puts "Item123 = #{attributes.inspect}"

    items = interface.select("select color from MyDomain where color = 'brick'")
    puts "Items = #{items.inspect}"

    interface.delete_domain("MyDomain")
  end

== Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

== Copyright

Copyright (c) 2010 JT Archie. See LICENSE for details.
