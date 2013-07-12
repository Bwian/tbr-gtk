files = Dir.entries(File.dirname(__FILE__)).select do |file|
  file =~ /^test_/
end
files.each {|file| require_relative file}
