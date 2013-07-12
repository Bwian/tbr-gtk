require 'time'

class CallDetail

# OBS record type DC - page 41
	
	attr_reader :call_type, :duration, :destination, :area, :start_date, :start_time, :cost
							
  def initialize(record,call_type)
  	fields = record.split(',')
  	if fields[0] == 'DC' && fields[8] == 'D' then  # Call Detail record
  		@call_type = call_type.desc(fields[9])
  		@duration = Time.at(fields[10].to_i).gmtime.strftime('%R:%S')
  		@destination = fields[12]
  		@area = fields[16]
  		@start_date = Time.parse(fields[18]).strftime('%d/%m/%Y')
  		@start_time = fields[20]
  		@cost = fields[33].to_f
  	else
  		raise ArgumentError, "Invalid record type - " + fields[0], caller
  	end
  end
  
end