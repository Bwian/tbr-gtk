require_relative 'services'
require_relative 'call_type'
require_relative 'service'
require_relative 'service_summary'
require_relative 'call_detail'
require_relative 'group'
require_relative 'groups'
require_relative 'create_files'

telstra = 'telstra.csv'
phones = 'phones.csv'
services = Services.new
groups = Groups.new
call_type = CallType.new
call_type.load(telstra)

file = File.new(phones)
file.each_line do |line|
	fields = line.split(',')
	group = groups.group(fields[1])
	service = services.service(fields[0])
	service.name = fields[2]
	service.cost_centre = fields[3]
	group.add_service(service)
end

invoice_date = ''
file = File.new(telstra)
file.each_line do |line|
	fields = line.split(',')
	service_number = fields[6]
	
	case fields[0]
		when "DH"
			invoice_date = fields[2]
			
		when "DS"
			service = services.service(service_number)
			service_summary = ServiceSummary.new(line,call_type)   
			service.add_service_summary(service_summary)
			
		when "DC"
			service = services.service(service_number)
			call_detail = CallDetail.new(line,call_type)   
			service.add_call_detail(call_detail)
	end	
end

group = groups.group('Unassigned')
services.each do |service|
	group.add_service(service) if service.name == 'Unassigned'
end

cf = CreateFiles.new(invoice_date)
groups.each do |group|
	cf.group_summary(group)
end

services.each do |service|
	cf.call_details(service)
end

cf.service_totals(services)

