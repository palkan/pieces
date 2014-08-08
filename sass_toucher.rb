require 'listen'
 
RE_PARTIAL = /_[a-zA-Z0-9_-]*\.sass$/
 
def all_sass_files
  ['./app/styles/**/*.sass'].
    map {|pattern| Dir[pattern]}.
    flatten.
    map {|file| File.expand_path file }
end
 
def compilable_sass_files
  all_sass_files.
    reject {|file| file =~ RE_PARTIAL }
end
 
def touch(file)
  puts "touched: #{file}"
  system %|touch #{file}|
end
 
targets = Dir.glob("app/styles/**/")

puts targets
 
listener = Listen.to *targets, filter: /\.*sass$/ do |modified, added, removed|
  file_to_run = (modified || added).first
  next if compilable_sass_files.include? file_to_run
  puts "changed: #{file_to_run}"
  compilable_sass_files.each {|f| touch f }
end

listener.start
sleep
 
Signal.trap 'INT' do
  exit
end