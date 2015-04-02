require 'camping' # camping framework
require 'json' # json library
require 'kramdown' # markdown gem
require 'fileutils' # file and dir manipulation library
require 'securerandom' # UUID fucntion
require 'haml' # html templating engine
require_relative 'persistence.rb' # redis post database, post class, and file class

## Setup ##
Camping.goes :Admin

module Admin
  
  def r404(path)  # 404 page
    render :_404
  end
  
  @@db = Persistence::RedisCategory.new('post', Persistence::BlogPost) # redis db of posts
  @@file_db = Persistence::RedisCategory.new('file', Persistence::FileLog) # redis db of files
  
end

## Routes ##
module Admin::Controllers

  class AdminPanel < R '/' # main admin panel
    def get
      render :admin
    end
  end
  
  ## Backup ##
  
  class BackupPanel < R '/backup' # backup panel
    def get
      render :backup_panel
    end
  end
  
  class BackupStatic < R '/backup/static' # sends json list of file urls (use with 'utils/backup.rb')
    def get
      
      static_file_links = @@file_db
        .all_items
        .collect { |item| [item.id, item.unique]}
        
      json = JSON.generate(static_file_links)
      
      @headers['Content-Disposition'] = 'attachment; filename=backup-static.json;'
      @headers['Content-Type'] = 'application/octet-stream'
      @headers['Content-Transfer-Encoding'] = 'binary'
      
      return json
      
    end
  end
  
  class BackupRedis < R '/backup/redis' # sends 'redis/dump.rdb'
    def get
 
      @headers['Content-Disposition'] = 'attachment; filename=dump.rdb;'
      @headers['Content-Type'] = 'application/octet-stream'
      @headers['Content-Transfer-Encoding'] = 'binary'
      
      return open('../redis/dump.rdb','rb') { |f| f.read }
      
    end
  end
  
  ## Post Browsing & Managment ##
  
  class EditorPanel < R '/edit' # list of posts (with link to editor)
    def get
    
      @posts = @@db
        .all_items
        .sort_by{ |item| item.create_time }
        .reverse
        
      render :post_panel
      
    end
  end
  
  class EditorRemovePost < R '/rm-post/' # removes post
    def post
    
      json = JSON.parse(@request.body.read)
      id = json['id']
      
      @@db.drop(id)
      
      @body = 'ok'
      
    end
  end
  
  class EditorToggleAccess < R '/toggle-post-access/' # toggles post visibility
    def post
    
      json = JSON.parse(@request.body.read)
      id = json['id']
      
      post = @@db.pull(id)
      access = (post.access == 'private') ? 'public' : 'private'
      @@db.update(id, {:access => access})
      
      @body = 'ok'
      
    end
  end
  
  class EditorPost < R '/edit-post/([^/]+)' # markdown editor
    def get(id)
      render :edit
    end
  end
  
  class EditorOut < R '/edit-out/([^/]+)' # fills markdown editor with existing post data
    def get(id)
    
      if id == 'new'
        @body = JSON.generate({:title => "", :tags => "", :md => ""})
      else
        post = @@db.pull(id)
        @body = JSON.generate({:title => post.title, :tags => post.tags,  :md => post.md})
      end
      
    end
  end
  
  class EditorIn < R '/edit-in/' # recieves editor posts
    def post
    
			json = JSON.parse(@request.body.read)
			title = json['title']
			time = Time.now.to_i.to_s
			md = json['md']
			html = Kramdown::Document.new(md).to_html.to_s
			tags = json['tags']
			
			if json['id'] == 'new' then # pushes a new BlogPost to the DB
			
			  post = Persistence::BlogPost.new(nil, title, time, md, html, tags, 'private')
			  @@db.push(post)
			  
			  @body = 'ok'
			  
			else # updates all fields of existing post, except :id, :create_time, and :access
			
			  id = json['id'].to_i
			  if not @@db.exists?(id) then return "Post, #{id}, does not exist..." end
			  @@db.update(id, {:title => title, :md => md, :html => html, :tags => tags})
			  
			  @body = 'ok'
			  
			end
    end
  end
  
  class EditorQuickPhotos < R '/qphotos/(.+)' # replies with list of markdown links to photos in ../static/"dir"
    def get(dir)
    
			photoExtensions = ['.jpg', '.webp', '.png', '.gif']
			dirItems = Dir.entries('../static/' + dir) - ['.', '..', '_system']

			dirPhotos = dirItems.select do |item|
			  file_extension = item
			    .match(/\.([0-9a-z]+$)/)
			    .to_s
			    .downcase
		    photoExtensions.include?(file_extension)
		  end
		  
			img_num = 0
			links = dirPhotos.collect do |item|
				img_num += 1
				"![img#{img_num}](/static/#{dir}/#{item})"
			end
			
			@body = JSON.generate(links)
			
    end
  end
  
  ## File Browsing & Managment ###
  
  class BrowserPanelRoot < R '/browser' # root browser panel
    def get
      
      paths = (Dir.entries('../static')-['.', '..', '_system']).sort
      is_dirs = paths.collect { |p| Dir.exist?("../static/#{p}") }
    
      @entries = paths.zip(is_dirs).collect { |p, d| {:path => p, :is_dir => d} }
      @current_dir = ''
      @upload_button = false
      
      render :browser_panel
      
    end
  end
  
  class BrowserPanel < R '/browser/(.+)' # "../static" browser panel
    def get(path)

      paths = (Dir.entries("../static/#{path}")-['.', '..', '_system']).sort
      is_dirs = paths.collect { |p| Dir.exist?("../static/#{p}") }
    
      @entries = paths.zip(is_dirs).collect { |p, d| {:path => p, :is_dir => d} }
      @current_dir = '/' + path
      @upload_button = true
      
      render :browser_panel
      
    end
    
    def post(path)

      @request.params['files'].each do |u_file|
        filename = u_file[:filename].gsub(' ', '_')
        File.open("../static/#{path}/#{filename}", 'wb') do |file|
			    file.puts u_file[:tempfile].read
			  end
			  file_log = Persistence::FileLog.new("static/#{path}/#{filename}", SecureRandom.uuid)
			  @@file_db.push(file_log)
      end
      
			redirect BrowserPanel, path
			
	  end
  end
  
  class BrowserDelete < R '/rm-file/'
    def post
    
      json = JSON.parse(@request.body.read)
      path = json['path']
      puts path
      
      FileUtils.remove_entry_secure("../static/#{path}")
      @@file_db.filter_clean("static#{path}")
      
      @body = 'ok'
      
    end
  end
  
  class BrowserRename < R '/rn-file/'
    def post
    
      json = JSON.parse(@request.body.read)
      path = json['path']
      old_name = json['old_name']
      new_name = json['new_name'].gsub(' ', '_')
      
      FileUtils.move("../static/#{path}/#{old_name}", "../static/#{path}/#{new_name}")
      
      @@file_db.drop("static/#{path}/#{old_name}")
      file_log = Persistence::FileLog.new("static/#{path}/#{new_name}", SecureRandom.uuid)
			@@file_db.push(file_log)
      
      @body = 'ok'
      
    end
  end
  
  class BrowserCreateDir < R '/new-dir'
    def post
    
      json = JSON.parse(@request.body.read)
      path = json['current_dir']
      name = json['name'].gsub(' ', '_')
      
      if path == 'null' then
        Dir.mkdir("../static/#{name}")
      else 
        Dir.mkdir("../static/#{path}/#{name}")
      end

      @body = 'ok'
      
    end
  end
	
end


## Views ##
module Admin::Views

  def _404
    
    template = Haml::Engine.new File.read('views/404.haml')
    
    template.render
    
  end
  
  def admin
    
    template = Haml::Engine.new File.read('views/admin.haml')
    
    template.render(Object.new, {:where => nil, :entries => nil})
    
  end
  
  def edit
    File.read('views/editor.html')
  end
  
  def post_panel
  
    template = Haml::Engine.new File.read('views/admin.haml')
    entry_template = Haml::Engine.new File.read('views/post-entry.haml')
    
    entries = @posts.each_with_index.collect do |p, i|
      entry_template.render(Object.new, {:post_num => i, :p => p})
    end
    entries_str = entries.join
    
    template.render(Object.new, {:where => 'edit', :entries => entries_str})
    
  end
  
  def browser_panel

    template = Haml::Engine.new File.read('views/admin.haml')
    entry_template = Haml::Engine.new File.read('views/file-entry.haml')
    
    entries = @entries.each_with_index.collect do |e, i|
      entry_template.render(Object.new, {:post_num => i, :entry => e, :current_dir => @current_dir})
    end
    entries_str = entries.join
    
    template.render(Object.new, {:where => 'browser', :entries => entries_str})
  end
  
  def backup_panel

    template = Haml::Engine.new File.read('views/admin.haml')
    entry_template = Haml::Engine.new File.read('views/backup-entry.haml')
    
    template.render(Object.new, {:where => 'backup', :entries => entry_template.render})
    
  end
  
end
