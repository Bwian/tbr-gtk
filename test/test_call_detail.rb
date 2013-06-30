require 'test/unit'
require_relative 'test_constants'
require_relative '../app/call_detail'
require_relative '../app/call_type'

class TestCallDetail < Test::Unit::TestCase
  def setup
  	call_type = CallType.new
  	call_type.load(CALL_TYPES)
  	@call_detail = CallDetail.new(DC_RECORD,call_type)   
  end

	def test_accessors
  	assert_equal('National Direct Dialled calls', @call_detail.call_type)
		assert_equal('00:25:40', @call_detail.duration)
  	assert_equal('53448577', @call_detail.destination)
		assert_equal('Ballarat', @call_detail.area)
  	assert_equal('13/03/2013', @call_detail.start_date)
		assert_equal('17:17:39', @call_detail.start_time)
		assert_equal(3.34, @call_detail.cost)
	end
	
	def test_invalid_record_type
		assert_raise ArgumentError do
			call_detail = CallDetail.new("XX",CallType.new)
		end
	end
	
end

  		
