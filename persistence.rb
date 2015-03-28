require 'redis' # redis gem

module Persistence

	BlogPost = Struct.new(:id, :title, :create_time, :md, :html, :tags, :access) # post container class
	
	FileLog = Struct.new(:id, :unique) # file container class
	
	class RedisCategory
	
	  def initialize(prefix, container, redis_options=nil) # new
	    if redis_options.nil? then @r = Redis.new
	    else @r = Redis.new(redis_options) end
	    @prefix = prefix
	    raise "class: #{container}, is missing :id property" if not container.members.include? :id
	    @container = container
	  end
	  
	  def exists?(id) # check if item exists
	    !@r.get("#{@prefix}:#{id}:id").nil?
	  end
	  
	  def new_id # get new id
	    top = 0
	    @r.keys("#{@prefix}:*:id").each do |key|
	      id = key.match(/\:(.*?)\:/)[1].to_i
	      if id > top then top = id end
	    end
	    return top + 1
	  end
	  
	  def pull(id) # get item (by id) from DB
	    item = @container.new
	    item.members.each {|property| item[property] = @r.get("#{@prefix}:#{id}:#{property.to_s}")}
	    return item
	  end
	  
	  def push(item) # add item to DB
	    if item.id.nil? then item.id = self.new_id end
	    item.each_pair {|property, value| @r.set("#{@prefix}:#{item.id}:#{property.to_s}", value)}
	  end
	  
	  def update(id, to_update) # update properties of item (by id)
	    to_update.each_pair {|property, value| @r.set("#{@prefix}:#{id}:#{property.to_s}", value)}
	  end
	  
	  def drop(id) # remove post (by id)
	    @container.members.each {|property| @r.del("#{@prefix}:#{id}:#{property.to_s}")}
	  end
	  
	  def move(id, other_category) # move item from this category to another (returns new item id)
	    if other_category.container != self.container then
	      raise "new category has different container type, #{other_category.container} instead of #{self.container}"
	    end
	    item = self.pull(id)
	    item.id = other_category.new_id
	    other_category.push(item)
	    self.drop(id)
	    return item.id
	  end
	  
	  def filter(&block) # returns list of items filtered by block
	    filtered = []
	    @r.keys("#{@prefix}:*:id").each do |key|
	      id = @r.get(key)
	      item = self.pull(id)
	      filtered << item if block.call(item)
	    end
	    return filtered
	  end
	  
	  def all_items # returns list of all items
	    return self.filter {true}
	  end
	  
	  def filter_clean(key_pattern) # selects items out of db by key_pattern and deletes them
	    to_delete_ids = @r.keys("#{@prefix}:#{key_pattern}*:id").collect {|id| id.split(':')[1]} 
	    to_delete_ids.each {|id| self.drop(id)}
	  end
	  
	end

end
