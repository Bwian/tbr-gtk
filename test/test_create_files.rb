require 'test/unit'
require 'fileutils'
require_relative '../app/create_files'

class TestCreateFiles < Test::Unit::TestCase
  def setup
  	FileUtils.rm_rf('./201304')
  	@cf = CreateFiles.new('20130418')   
  end

	def teardown
  	FileUtils.rm_rf('./201304')   
  end
  
	def test_accessors
		assert_equal('April 2013',@cf.invoice_month)
		assert_equal('./201304', @cf.dir_root)
		assert(Dir.exist?('./201304/summaries'))
		assert(Dir.exist?('./201304/details'))
	end
	
	def test_invalid_invoice_date
		assert_raise ArgumentError do
			cf = CreateFiles.new("")
		end	
	end
	
	def test_already_exists
		assert_raise RuntimeError do
			cf = CreateFiles.new('20130418')
		end
	end
	
	def test_no_date
		assert_raise ArgumentError do
			CreateFiles.new('') 
		end
	end
	
	# TODO: test file creation methods
end
