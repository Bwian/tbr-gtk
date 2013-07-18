require_relative 'process_bills'
require_relative 'helper'
require_relative 'log_it'

# require 'debugger'; debugger

BILL_FILE		= './data/telstra.csv'
CONFIG_FILE	= './config/services.csv'

helper = Helper.new
log = LogIt.instance

if !helper.check_directory_structure && helper.yn("Rebuild directory structure in #{Dir.pwd}",'y')
  helper.fix_directory_structure
end

exit if !helper.check_directory_structure  # Still no directory 

if !File.exists?(CONFIG_FILE)
  if helper.yn("Configuration file #{CONFIG_FILE} does not exist.  Create?","n")
    f = File.open(CONFIG_FILE,'w')
    f.close
    puts 'Warning - all services will be classified as unassigned.'
    log.warn("Configuration file #{CONFIG_FILE} created as zero length")
  else
    exit
  end
end

process_bills = ProcessBills.new(nil,nil)
process_bills.run(CONFIG_FILE,BILL_FILE)