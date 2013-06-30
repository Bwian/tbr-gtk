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

BILL_FILE		= 'telstra.csv'
CONFIG_FILE	= 'config/services.csv'
UNASSIGNED	= 'Unassigned'

LogIt.to_file('./logs/telstra.log')

call_type = CallType.new
call_type.load(BILL_FILE)

services = Services.new
groups = Groups.new

ParseFiles.map_services(groups,services,CONFIG_FILE)
invoice_date = ParseFiles.parse_bill_file(services,call_type,BILL_FILE)

group = groups.group(UNASSIGNED)
services.each do |service|
	group.add_service(service) if service.name == UNASSIGNED
end

cf = CreateFiles.new(invoice_date)
groups.each do |group|
	cf.group_summary(group)
end

services.each do |service|
	cf.call_details(service)
end

cf.service_totals(services)

