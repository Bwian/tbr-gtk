class ParseFiles
	SERVICE_NUMBER	= 0
	SERVICE_GROUP		= 1
	SERVICE_NAME		= 2
	SERVICE_CC			= 3
	
	def self.map_services(groups,services,config_file)
		begin
			file = File.new(config_file)
				
			file.each_line do |line|
				fields = line.split(',')
				next if !valid_fields(fields)
				
				group = groups.group(fields[SERVICE_GROUP])
				service = services.service(fields[SERVICE_NUMBER])
				service.name = fields[SERVICE_NAME]
				service.cost_centre = fields[SERVICE_CC]
				group.add_service(service)
			end
		rescue Errno::ENOENT
			raise IOError, "Error accessing configuration file #{config_file}"
		end
	end
	
	def self.parse_bill_file(services,call_type,bill_file)
		invoice_date = ''
		file = File.new(bill_file)
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
		invoice_date
	end
	
	def self.valid_fields(fields)
		return false if fields.size == 0
		
		if fields.size < 4
			#TODO: replace with logging
			warn("Invalid configuration record: #{} - #{fields.to_s}")
			return false
		end
		
		return true
	end
	
	private_class_method :valid_fields
end