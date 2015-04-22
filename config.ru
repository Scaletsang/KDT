require 'camping'
require 'camping/server'

blog = Camping::Server.new(:script => 'blog.rb')
admin = Camping::Server.new(:script => 'admin.rb')

#\ -o 0.0.0.0 -p 3301

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
      
      File.read('../admin.txt').strip
      
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
	
