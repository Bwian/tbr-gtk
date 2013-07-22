require 'simplecov'
SimpleCov.start
@@test_dialogs = false  # Set to true to test gui and console output

files = Dir.entries(File.dirname(__FILE__)).select do |file|
  file =~ /^test_/
end
files.each {|file| require_relative file}
