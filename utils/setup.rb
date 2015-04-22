require 'fileutils'

def make_if_not_exist(path)
  if not Dir.exist?(path) then Dir.mkdir(path_inner) end
end


# manage content directories
make_if_not_exist '../static'
make_if_not_exist '../redis'
File.open('../redis/redis.conf', 'w') { |f| f << File.read('config_templates/redis.conf') } if not File.exists? '../redis/redis.conf'
File.open('../admin.txt', 'w') { |f| f << 'kittens' } if not File.exists? '../admin.txt'

# setup unicorn config and directories
make_if_not_exist 'tmp'
make_if_not_exist 'tmp/sockets'
make_if_not_exist 'tmp/pids'
make_if_not_exist 'log'
File.open('unicorn.rb', 'w') { |f| f << File.read('config_templates/unicorn.rb').gsub('##path##', Dir.pwd) }

# nginx config
nginx_conf = File.read('config_templates/nginx.conf').gsub('##path##', Dir.pwd).gsub('##static##', File.expand_path('../static'))
FileUtils.mv '/usr/local/etc/nginx/nginx.conf', '/usr/local/etc/nginx/nginx.conf.backup'
File.open('/usr/local/etc/nginx/nginx.conf', 'w+') { |f| f << nginx_conf }
