require 'camping'
require 'camping/server'

blog = Camping::Server.new(:script => 'blog.rb')
admin = Camping::Server.new(:script => 'admin.rb')

#\ -o 0.0.0.0 -p 3301

# for development ease, in production start & manage separately
spawn 'redis-server redis/redis.conf'

app = Rack::Builder.app do

  use Rack::Static, :urls => ["/static"]
  
	map '/' do
	  run blog
	end
	
	map '/admin' do
	  unique = srand.to_s
	  use Rack::Auth::Digest::MD5, "Admin", unique do |username|
      # This is the admin password
      # Change it before production...
      'kittens'
    end
	  run admin
	end
	
end

run app
	
