require_relative 'create_files'
require_relative 'process_bills'
require_relative 'helper'
require_relative 'log_it'

# require 'debugger'; debugger

BILL_FILE		  = './data/telstra.csv'
SERVICES_FILE	= './config/services.csv'
LOG_FILE      = './logs/telstra.log'

helper = Helper.new
LogIt.instance.to_file(LOG_FILE) # Initialise logging

if !helper.check_directory_structure && helper.yn("Rebuild directory structure in #{Dir.pwd}",'y')
  helper.fix_directory_structure
end

exit if !helper.check_directory_structure  # Still no directory 

if !File.exists?(SERVICES_FILE)
  if helper.yn("Services configuration file #{SERVICES_FILE} does not exist.  Create?","n")
    f = File.open(SERVICES_FILE,'w')
    f.close
    puts 'Warning - all services will be classified as unassigned.'
    log.warn("Services configuration file #{SERVICES_FILE} created as zero length")
  else
    exit
  end
end

process_bills = ProcessBills.new
process_bills.run(SERVICES_FILE,BILL_FILE,true)