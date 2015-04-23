require 'open-uri'
require 'json'
require 'fileutils'

site_url = 'http://kdt.io'

old_backup = if File.exist?('backup-static-old.json') then
  puts 'Found previous backup index...'
  File.read('backup-static-old.json') 
  else '[]'
end

new_backup = if File.exist?('backup-static.json') then
  puts 'Found new backup index...'
  File.read('backup-static.json') 
  else raise 'Couldn\'t find new backup index!'
end

old_uuids = JSON.parse(old_backup).collect { |item| item[1] }
new_file_list = JSON.parse(new_backup)

def path_create(path)
  split_path = path.split('/')[0..-2]
  path_inner = ''
  split_path.each do |p|
    path_inner << (p + '/')
    if not Dir.exist?(path_inner) then
      Dir.mkdir(path_inner)
    end
  end
end
  

new_file_list.each do |path, uuid|
  begin
    if not old_uuids.include?(uuid) then
      puts "Downloading: #{path}..."
      path_create(path)
      file_name = path.split('/').last
      open(path, 'wb') do |f|
        f << open("#{site_url}/#{path}").read
      end
    end
  rescue StandardError
    puts "Backing up file: #{path}, failed..."
  end
end

puts 'Renaming backup index...'
FileUtils.move('backup-static.json', 'backup-static-old.json')

puts 'Done!'
