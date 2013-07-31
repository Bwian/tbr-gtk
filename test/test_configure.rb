require 'minitest/autorun'
require_relative '../app/configure'

class TestConfigure < MiniTest::Test
  def setup
    @config = Configure.new('./test/data/config.yaml') 
  end

	def test_accessors
    assert_equal('./DATA',@config.data)
    assert_equal('./DATA/archive',@config.archive)
    @config.data = 'data'
    assert_equal('data',@config.data)
    @config.archive = 'archive'
    assert_equal('archive',@config.archive)   
	end
  
  def test_missing_config_file
    config = Configure.new('./test/data/missing.yaml')
    assert_equal('./data',config.data)
    assert_equal('./data/archive',config.archive)
  end
  
  def test_invalid_config_file
    config = Configure.new('./test/data/invalid.yaml')
    assert_equal('./data',config.data)
    assert_equal('./data/archive',config.archive)
  end
  
  def test_update_config_file
    newfile = './test/data/new.yaml'
    FileUtils.rm_rf(newfile)
    config = Configure.new(newfile)
    refute(config.changed?,'Before change')
    config.data = './datanew'
    assert(config.changed?,'After change')
    config.update
    refute(config.changed?,'After update')
    assert_equal(57,File.size(newfile))
    FileUtils.rm_rf(newfile)
  end
end

  		
