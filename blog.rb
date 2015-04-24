require 'camping' # camping framework
require 'haml' # html templating engine
require_relative 'persistence.rb' # redis post database & post class

## Setup ##
Camping.goes :Blog

module Blog
  
  def r404(path) # 404 page
    render :_404
  end
  
  @@db = Persistence::RedisCategory.new('post', Persistence::BlogPost) # redis db of posts
  
end

## Routes ##
module Blog::Controllers
  
  class Index < R '/' # root
    def get
      
      @posts = @@db
        .all_items
        .select { |p| p.access == 'public' }
        .sort_by { |p| p.create_time }
        .reverse
        .take 5
        
      @with_title_links = true
      @more_link = if (@posts.length - 5) >= 0
        then '/home/1'
        else nil
      end
      
      render :blog
      
    end
  end
  
  class About < R '/about' # about page
    def get
      render :about
    end
  end
  
  class Home < R '/home' # home
    def get
      redirect HomeN, 0
    end
  end
  
  class HomeN < R '/home/(\d+)' # home (with page_num)
    def get(page_num)
    
      @posts = @@db
        .all_items
        .select { |p| p.access == 'public' }
        .sort_by { |p| p.create_time }
        .reverse
        .drop(page_num.to_i * 5)
        .take 5
        
      @with_title_links = true
      @more_link = if (@posts.length - ((page_num.to_i + 1) * 5)) >= 0
        then "/home/#{page_num.to_i + 1}"
        else nil
      end
      
      render :blog
      
    end
  end
  
  class Post < R '/post/(\d+)' # post (specified by id)
	  def get(id)
	    
	    @posts = [@@db.pull(id)].select{ |p| p.access == 'public' }
	    
	    @with_title_links = false
	    @more_link = nil
	    
	    if @posts.empty?
	      then r404("/post/#{id}")
	      else render :blog
	    end
	    
	  end
	end
	
	class Tag < R '/tag/([^/]+)' # retrieves top 5 posts with tag
	  def get(tag)
	    redirect TagN, tag, 0
	  end
  end
  
  class TagN < R '/tag/([^/]+)/(\d+)' # retrieves nth page of posts with tag
    def get(tag, page_num)
      
      @posts = @@db
        .filter { |p| p.tags.split("+").include?(tag) }
        .select { |p| p.access == 'public' }
        .sort_by { |p| p.create_time }
        .reverse
        .drop(page_num.to_i * 5)
        .take 5
      
      @with_title_links = true
      @more_link = if (@posts.length - ((page_num.to_i + 1) * 5)) >= 0
        then "/tag/#{tag}/#{page_num.to_i + 1}"
        else nil
      end
      
      render :blog
      
    end
  end
  
  class RSS < R '/rss' # RSS feed
    def get
    
      @rss_entries = @@db
        .all_items
        .select { |p| p.access == 'public' }
        .sort_by { |p| p.create_time }
        .reverse
        .take 10
      
      @headers['Content-Type'] = 'text/xml'  
      render :rss  
    
    end
  end
  
  class StaticPage < R '/~/([^/]+)'
    def get(page_name)
      
      if File.exists?("../static/#{page_name}/index.html") then
        File.read("../static/#{page_name}/index.html")
      else
        render :_404
      end
      
    end
  end

end

## Views ##
module Blog::Views
  
  def _404
  
    template = Haml::Engine.new File.read('views/404.haml')
    
    template.render
    
  end
  
  def about
  
    template = Haml::Engine.new File.read('views/blog.haml')
    about = Haml::Engine.new File.read('views/about.haml')
    
    template.render(Object.new, {:content => about.render, :more_link => nil})
    
  end
  
  def blog
  
    template = Haml::Engine.new File.read('views/blog.haml')
    post_template = Haml::Engine.new File.read('views/post.haml')
    
    @content = @posts.collect { |p| post_template.render(Object.new, {:post => p, :link => @with_title_links}) }.join
    
    template.render(Object.new, {:content => @content, :more_link => @more_link})
    
  end
  
  def rss
  
    template = Haml::Engine.new File.read('views/rss.haml')
    entry_template = Haml::Engine.new File.read('views/rss-entry.haml')
    
    @content = @rss_entries.collect { |p| entry_template.render(Object.new, {:post => p}) }.join
    
    template.render(Object.new, {:content => @content})
    
  end
  
end


