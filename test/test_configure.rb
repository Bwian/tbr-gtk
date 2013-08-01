require 'minitest/autorun'
require_relative '../app/configure'

class TestConfigure < MiniTest::Test
  def setup
    @config = Configure.instance
    @config.file = './test/data/config.yaml'
  end

  def test_accessors      
    assert_equal('./DATA',@config.data)
    assert_equal('./DATA/archive',@config.archive)
    @config.data = 'data'
    assert_equal('data',@config.data)
    @config.archive = 'archive'
    assert_equal('archive',@config.archive)   
  end
  
	def test_singleton
		a = Configure.instance
		b = Configure.instance
		assert_equal(a,b)
	end
  
  def test_nil_config_file
    invalid_file(nil)
  end
    
  def test_missing_config_file
    invalid_file('./test/data/missing.yaml')
  end
  
  def test_invalid_config_file
    invalid_file('./test/data/invalid.yaml')
  end
  
  def test_update_config_file
    newfile = './test/data/new.yaml'
    FileUtils.rm_rf(newfile)
    @config.file = newfile
    refute(@config.changed?,'Before change')
    @config.data = './datanew'
    assert(@config.changed?,'After change')
    @config.update
    refute(@config.changed?,'After update')
    assert_equal(57,File.size(newfile))
    FileUtils.rm_rf(newfile)
  end
  
  def test_extra
    @config.file = './test/data/extra.yaml'
    assert_equal('./extra',@config.data)
    assert_nil(@config.archive)
    assert_equal('./extra/extra',@config.extra)
  end
  
  private
  
  def invalid_file(file)
    @config.file = file
    assert_equal('./data',@config.data)
    assert_equal('./data/archive',@config.archive)
  end
end

  		
