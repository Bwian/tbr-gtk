require 'test/unit'
#require_relative 'test_constants'
require_relative '../app/parse_files'
#require_relative '../app/service'
#require_relative '../app/service_summary'

class TestParseFiles < Test::Unit::TestCase
  def setup
  	@call_type = CallType.new
  	@call_type.load('test/tc.csv') 
  	@services = Services.new
		@groups = Groups.new	
  end

	def test_map_services
		ParseFiles.map_services(@groups,@services,'test/test_services.csv')
		assert_equal(3,@groups.size)
		assert_equal(14,@services.size)
	end
	
	def test_missing_config
		assert_raise IOError do
			ParseFiles.map_services(@groups,@services,'test/missing.csv')
		end
	end
	
	def test_valid_fields
		assert(!ParseFiles.send(:valid_fields,''.split(',')))
		assert(!ParseFiles.send(:valid_fields,'A,B,C'.split(',')))
	end
end
