require_relative 'process_bills'

# require_relative 'services'
# require_relative 'call_type'
# require_relative 'service'
# require_relative 'service_summary'
# require_relative 'call_detail'
# require_relative 'group'
# require_relative 'groups'
# require_relative 'create_files'
# require_relative 'parse_files'
# require_relative 'log_it'

# require 'debugger'; debugger

BILL_FILE		= './data/telstra.csv'
CONFIG_FILE	= './config/services.csv'

process_bills = ProcessBills.new(nil,nil)
process_bills.run(CONFIG_FILE,BILL_FILE)