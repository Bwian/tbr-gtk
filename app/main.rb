require_relative 'process_bills'



# require 'debugger'; debugger

BILL_FILE		= './data/telstra.csv'
CONFIG_FILE	= './config/services.csv'

process_bills = ProcessBills.new(nil,nil)
process_bills.run(CONFIG_FILE,BILL_FILE)