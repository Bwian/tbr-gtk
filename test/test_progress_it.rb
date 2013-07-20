require 'minitest/autorun'
require'fileutils'
require 'gtk2'
 
require_relative '../app/progress_it'

class TestProgressIt < MiniTest::Test 
  
  def setup
  	@progress = ProgressIt.instance
    @progress.zero
    @progress.total = 100
    @progress.bar = nil
  end
	
	def test_singleton
		a = ProgressIt.instance
		b = ProgressIt.instance
		assert_equal(a,b)
	end
	
  def test_accessors
    assert_equal(0,@progress.count)
    assert_equal(100,@progress.total)
    assert_nil(@bar)
    @progress.total = 50
    assert_equal(50,@progress.total)
  end
  
  def test_increment_and_zero
    @progress.increment
    assert_equal(1,@progress.count)
    @progress.zero
    assert_equal(0,@progress.count)
  end
  
  def test_bar
    @progress.bar = MockBar.new
    @progress.increment
    assert_equal(0.01,@progress.bar.fraction)
  end
end

class MockBar
  attr_accessor :fraction
end