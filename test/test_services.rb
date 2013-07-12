require 'minitest/autorun'
require_relative '../app/services'
require_relative '../app/service'

class TestServices < MiniTest::Test
  def setup
  	@services = Services.new   
  end

	def test_add_services
		assert_equal(0,@services.size)
		
		@services.service('418501461')
		assert_equal(1,@services.size)
		
		@services.service('418501462')
		assert_equal(2,@services.size)
		
		@services.service('418501461')
		assert_equal(2,@services.size)	
	end
	
	def test_each
		load_services
		
		count = 0
		@services.each do |service|
			count += 1
		end
		assert_equal(2,count)
	end
	
	def test_delete
		load_services
		assert_equal(2,@services.size)
		@services.delete('418501461')
		assert_equal(1,@services.size)
	end
	
	private
	
	def load_services
		@services.service('418501461')
		@services.service('418501462')
	end
end
