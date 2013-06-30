require 'test/unit'
#require_relative 'test_constants'
require_relative '../app/parse_files'
#require_relative '../app/service'
#require_relative '../app/service_summary'

class TestParseFiles < Test::Unit::TestCase
  def setup
  	@call_type = CallType.new
  	@call_type.load(CALL_TYPES)
  	@services = Services.new
		@groups = Groups.new	
  end

	def test_map_services
		ParseFiles.map_services(@groups,@services,SERVICES)
		assert_equal(3,@groups.size)
		assert_equal(14,@services.size)
	end
	
	def test_missing_config
		assert_raise IOError do
			ParseFiles.map_services(@groups,@services,MISSING)
		end
	end
	
	def test_parse_bill_file
		ParseFiles.map_services(@groups,@services,SERVICES)		
		invoice_date = ParseFiles.parse_bill_file(@services,@call_type,BILLS)
		assert_equal('20130619',invoice_date)
		service = @services.service('0418133125')
		assert_equal(8,service.service_summaries.size)
		assert_equal(147,service.call_details.size)
	end
	
	def test_missing_bill_file
		assert_raise IOError do
			ParseFiles.parse_bill_file(@services,@call_type,MISSING)
		end
	end
	
	def test_valid_fields
		assert(!ParseFiles.send(:valid_fields,''.split(',')))
		assert(!ParseFiles.send(:valid_fields,'A,B,C'.split(',')))
		assert(ParseFiles.send(:valid_fields,'A,B,C,D'.split(',')))
	end
end
