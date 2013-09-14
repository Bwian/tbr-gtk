require 'minitest/autorun'
require_relative '../app/configure'

class TestConfigure < MiniTest::Test
  def setup
    @config = Configure.instance
    @config.file = './test/data/config.yaml'
  end

  def teardown
    @config.file = nil  # reset configuration for subsequent tests
  end
  
  def test_accessors      
    assert_equal('./DATA',@config.input)
    assert_equal('./DATA',@config.output)
    assert_equal('./DATA/archive',@config.archive)
    assert_equal('./config', @config.services)
    @config.input = 'input'
    assert_equal('input',@config.input)
    @config.output = 'output'
    assert_equal('output',@config.output)
    @config.archive = 'archive'
    assert_equal('archive',@config.archive)
    @config.services = 'services'
    assert_equal('services',@config.services)   
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
    @config.input = './datanew'
    assert(@config.changed?,'After change')
    @config.update
    refute(@config.changed?,'After update')
    assert_equal(101,File.size(newfile))
    FileUtils.rm_rf(newfile)
  end
  
  def test_extra
    @config.file = './test/data/extra.yaml'
    assert_equal('./extra',@config.input)
    assert_nil(@config.archive)
    assert_equal('./extra/extra',@config.extra)
  end
  
  def test_each
    test = {
      'input'    => './input',
      'output'   => './output',
      'archive'  => './data/archive',
      'services' => './config' 
    } 
      
    @config.each do |key,value|
      test.delete(key)
    end
    
    assert_equal(0,test.size)
  end
  
  def test_reset
    @config.input = './something/new'
    @config.reset
    assert_equal('./DATA',@config.input)
  end
  
  private
  
  def invalid_file(file)
    @config.file = file
    assert_equal('./data',@config.input)
    assert_equal('./data/archive',@config.archive)
  end
end

  		
