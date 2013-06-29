# files = Dir.entries(File.dirname(__FILE__)).select do |file|
# 	file =~ /^test_/
# end
# files.each {|file| require file}

require_relative 'test_call_type'
require_relative 'test_service'
require_relative 'test_service_summary'
require_relative 'test_call_detail'
require_relative 'test_services'
require_relative 'test_group'
require_relative 'test_groups'
require_relative 'test_create_files'
require_relative 'test_parse_files'
