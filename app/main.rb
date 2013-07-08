require_relative 'services'
require_relative 'call_type'
require_relative 'service'
require_relative 'service_summary'
require_relative 'call_detail'
require_relative 'group'
require_relative 'groups'
require_relative 'create_files'
require_relative 'parse_files'
require_relative 'log_it'

# require 'debugger'; debugger

BILL_FILE		= './data/telstra.csv'
CONFIG_FILE	= './config/services.csv'
UNASSIGNED	= 'Unassigned'

LogIt.instance.to_file('./logs/telstra.log')
LogIt.instance.info("Starting Telstra Billing Data Extract")

LogIt.instance.info("Extracting Call Types from #{BILL_FILE}")
call_type = CallType.new
call_type.load(BILL_FILE)

services = Services.new
groups = Groups.new

LogIt.instance.info("Mapping services from #{CONFIG_FILE}")
ParseFiles.map_services(groups,services,CONFIG_FILE)
LogIt.instance.info("Extracting billing data from #{BILL_FILE}")
invoice_date = ParseFiles.parse_bill_file(services,call_type,BILL_FILE)

LogIt.instance.info("Building Unassigned group")
group = groups.group(UNASSIGNED)
services.each do |service|
	group.add_service(service) if service.name == UNASSIGNED
end

cf = CreateFiles.new(invoice_date)
LogIt.instance.info("Creating group summaries")
groups.each do |group|
	cf.group_summary(group)
end

LogIt.instance.info("Creating service details")
services.each do |service|
	cf.call_details(service)
end

LogIt.instance.info("Creating service totals summary")
cf.service_totals(services)

LogIt.instance.info("Telstra Billing Data Extract completed.")
