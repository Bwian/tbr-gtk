require 'test/unit'
require_relative '../app/groups'

class TestGroups < Test::Unit::TestCase
  def setup
  	@groups = Groups.new   
  end

	def test_add_groups
		assert_equal(0,@groups.size)
		
		@groups.group('Brian')
		assert_equal(1,@groups.size)
		
		@groups.group('Frank')
		assert_equal(2,@groups.size)
		
		@groups.group('Brian')
		assert_equal(2,@groups.size)
	end
	
	def test_size
		@groups.group('Brian')
		@groups.group('Frank')
		
		count = 0
		@groups.each do |group|
			count += 1
		end
		assert_equal(2,count)
	end
end
