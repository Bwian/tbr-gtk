require 'test/unit'
require_relative 'test_constants'
require_relative '../app/call_type'

class TestCallType < Test::Unit::TestCase
  def setup
  	@call_type = CallType.new
  	@call_type.load(CALL_TYPES)
  end

	def test_load
		assert_equal(3,@call_type.size)
	end
	
  def test_invalid_call_type
    assert_equal('Unknown service type - XXXXX',@call_type.desc('XXXXX'))
  end
  
  def test_valid_call_type
  	assert_equal('Directory charges',@call_type.desc('00002'))
  end

end
