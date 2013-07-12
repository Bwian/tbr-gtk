require 'minitest/autorun'
require_relative 'test_constants'
require_relative '../app/service'
require_relative '../app/service_summary'
require_relative '../app/call_type'
require_relative '../app/call_detail'

class TestService < MiniTest::Test
  def setup
  	@service = Service.new(TEST_PHONE,'Brian Collins','1000')
  	@call_type = CallType.new
  	@call_type.load(CALL_TYPES)
  end

	def test_accessors
		assert_equal(TEST_PHONE, @service.service_number)
		assert_equal('Brian Collins', @service.name)
		assert_equal(0,@service.service_summaries.size)
		assert_equal(0,@service.call_details.size)
	end
	
	def test_add_service_summary
		service_summary = ServiceSummary.new(DS_RECORD,@call_type)   
		@service.add_service_summary(service_summary)
		assert_equal(1,@service.service_summaries.size)
		assert_equal(TEST_PHONE,@service.service_summaries[0].service_number)
	end
	
	def test_add_call_detail
		call_detail = CallDetail.new(DC_RECORD,@call_type)   
		@service.add_call_detail(call_detail)
		assert_equal(1,@service.call_details.size)
		assert_equal('Ballarat',@service.call_details[0].area)
	end
	
	def test_change_name
		@service.name = 'Francis Bacon'
		assert_equal('Francis Bacon', @service.name)
		@service.name = nil
		assert_equal('Unassigned', @service.name)
	end
	
	def test_nil_name
		@service = Service.new(TEST_PHONE,nil,nil)
		assert_equal('Unassigned', @service.name)
	end
	
	def test_change_cost_centre
		@service.cost_centre = '2000'
		assert_equal('2000', @service.cost_centre)
		@service.cost_centre = nil
		assert_equal('', @service.cost_centre)
	end
	
	def test_nil_cost_centre
		@service = Service.new(TEST_PHONE,nil,nil)
		assert_equal('', @service.cost_centre)
	end
	
	def test_total
		assert_equal(0.0,@service.total)
		service_summary = ServiceSummary.new(DS_RECORD,@call_type)   
		@service.add_service_summary(service_summary)
		assert_equal(46.48,@service.total)
	end
	
	def test_service_number_format
		assert_equal("04 1850 1461",@service.service_number_format)
		@service = Service.new('1234567890','Brian Collins','1000')
		assert_equal("1234567890",@service.service_number_format)
	end
end
