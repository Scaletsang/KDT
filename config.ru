require 'camping'
require 'camping/server'

blog = Camping::Server.new(:script => 'blog.rb')
admin = Camping::Server.new(:script => 'admin.rb')

#\ -o 0.0.0.0 -p 3301

# manage content directories
Dir.mkdir('../static') if not Dir.exists? '../static'
Dir.mkdir('../redis') if not Dir.exists? '../redis'
File.open('../redis/redis.conf', 'w') { |f| f << File.read('redis.conf') } if not File.exists? '../redis/redis.conf'
File.open('../admin.txt', 'w') { |f| f << 'kittens' } if not File.exists? '../admin.txt'


app = Rack::Builder.app do

  use Rack::Static, :urls => ["/system"]
  
	map '/' do
	  run blog
	end
	
	map '/admin' do
	  unique = srand.to_s
	  use Rack::Auth::Digest::MD5, "Admin", unique do |username|
      # This is the admin password
      # Change it before production...
      
      File.read '../admin'
      
      # And yes, it is stored in a cleartext file called admin.txt
      # May the security gods have mercy on my soul...
    end
	  run admin
	end
  
  map "/static" do
    run Rack::File.new('../static')
  end
  
end

run app
	
