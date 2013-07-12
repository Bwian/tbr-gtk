require 'minitest/autorun'
require_relative 'test_constants'
require_relative '../app/service_summary'
require_relative '../app/call_type'

class TestServiceSummary < MiniTest::Test
  def setup
  	call_type = CallType.new
  	call_type.load(CALL_TYPES)
  	@service_summary = ServiceSummary.new(DS_RECORD,call_type)   
  end

	def test_accessors
		assert_equal(TEST_PHONE,@service_summary.service_number)
		assert_equal('National Direct Dialled calls',@service_summary.call_type)
		assert_equal('MobileNet',@service_summary.service_type)
		assert_equal('calls',@service_summary.units)
		assert_equal(67,@service_summary.call_count)
		assert_equal('12/03/2013',@service_summary.start_date)
		assert_equal('10/04/2013',@service_summary.end_date)
		assert_equal(46.48,@service_summary.cost)
	end
	
	def test_invalid_record_type
		assert_raises ArgumentError do
			service_summary = ServiceSummary.new("XX",CallType.new)
		end
	end
	
	def test_to_a
		assert_equal(5,@service_summary.to_a.size)
		assert_equal("46.48",@service_summary.to_a[4])
	end
end
