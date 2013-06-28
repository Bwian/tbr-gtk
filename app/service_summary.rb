require 'time'

class ServiceSummary

# OBS record type DS - page 30
	attr_reader :service_number, :call_type, :service_type, :units, :call_count,
							:start_date, :end_date, :cost

  def initialize(record,call_type)
  	fields = record.split(',')
  	if fields[0] == 'DS' && fields[8] == 'D' then  # Service Summary and Detail record
  		@service_number = fields[6]
  		@call_type = call_type.desc(fields[10])
  		@service_type = fields[11]
  		@units = fields[12]
  		@call_count = fields[13].to_i
  		@start_date = Time.parse(fields[15]).strftime('%d/%m/%Y')
  		fields[16] == '' ? @end_date = '' : @end_date = Time.parse(fields[16]).strftime('%d/%m/%Y')
  		@cost = fields[33].to_f
  	else
  		raise ArgumentError, "Invalid record type - " + fields[0], caller
  	end
  end
  
  def to_a
  	call_count = @call_count == 0 ? call_count = "" : call_count = sprintf("%d",@call_count)
  	cost = sprintf("%0.2f",@cost)
  	[@call_type, @service_type, call_count, @units, cost]
  end
end
