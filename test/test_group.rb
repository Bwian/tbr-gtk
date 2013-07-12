require 'minitest/autorun'

require_relative 'test_constants'
require_relative '../app/service'
require_relative '../app/group'

class TestGroup < MiniTest::Test
  def setup
  	@group = Group.new('Brian')
  end

	def test_accessors
		assert_equal('Brian', @group.name)
		assert_equal(0,@group.size)
	end
	
	def test_add_service
		service = Service.new(TEST_PHONE,'Brian Collins','1000')
		@group.add_service(service)
		assert_equal(1,@group.size)
	end
	
	def test_each
		service = Service.new(TEST_PHONE,'Brian Collins','1000')
		@group.add_service(service)
		service = Service.new('0418501462','Frank Collins','1000')
		@group.add_service(service)
		
		count = 0
		@group.each do |service|
			count += 1
		end
		assert_equal(2,count)
	end
end
