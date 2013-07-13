require 'minitest/autorun'
require'fileutils'
 
require_relative '../app/log_it'

class TestLogIt < MiniTest::Test 
  def setup
  	@log = LogIt.instance
  end

	def teardown
		@log.to_null
	end
	
	def test_singleton
		a = LogIt.instance
		b = LogIt.instance
		assert_equal(a,b)
	end

# 	Uncomment to test logging to STDOUT and STDERR

# 	def test_to_stdout
# 		@log.to_stdout
# 		@log.warn("STDOUT - Hello World")
# 	end
# 	
# 	def test_to_stderr
# 		@log.to_stderr
# 		@log.warn("STDERR - Hello World")
# 	end	
	
	
	def test_to_file
		fname = './test/test.log'
		FileUtils.rm_rf(fname)
		@log.to_file(fname)
		@log.warn("Hello World")
		@log.close
		
		assert(File.size(fname) > 0)
    FileUtils.rm_rf(fname)
	end	
end
