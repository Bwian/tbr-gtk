require 'minitest/autorun'
require 'fileutils'
require_relative '../app/create_files'

class TestCreateFiles < MiniTest::Test
  def setup
  	FileUtils.rm_rf('./data/201304')
  	@cf = CreateFiles.new('20130418',false)   
  end

	def teardown
    FileUtils.rm_rf('./data/201304')   
  end
  
	def test_accessors
		assert_equal('April 2013',@cf.invoice_month)
		assert_equal('./data/201304', @cf.dir_root)
		assert(Dir.exist?('./data/201304/summaries'))
		assert(Dir.exist?('./data/201304/details'))
	end
	
	def test_invalid_invoice_date
		assert_raises ArgumentError do
			CreateFiles.new("",false)
		end	
	end
	
	def test_already_exists
		assert_raises IOError do
			CreateFiles.new('20130418',false)
		end
	end
  
  def test_dir_full_root
    assert_equal(File.realdirpath(@cf.dir_root),@cf.dir_full_root)
  end
  
  def test_archive
    FileUtils.rm_rf('./data/bills*.csv')
    FileUtils.cp('./test/data/bills.csv', './data/bills.csv')
    CreateFiles.archive('./data/bills.csv')
    assert(Dir.glob('./data/bills*.csv').empty?)  
    assert(!Dir.glob('./data/archive/bills*.csv').empty?)  
    FileUtils.rm_rf('./data/archive/bills*.csv')   
  end
	
	# TODO: test file creation methods
end
