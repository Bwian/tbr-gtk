require 'time'

class ServiceSummary

# OBS record type DS - page 30
	
	DS_CODE					= 0
	DS_SERVICE			= 6
	DS_TYPE					= 8
	DS_CALL_TYPE		= 10
	DS_SERVICE_TYPE	= 11
	DS_UNITS				= 12
	DS_CALL_COUNT		= 13
	DS_START_DATE		= 15
	DS_COST					= 33
	
	attr_reader :service_number, :call_type, :service_type, :units, :call_count,
							:start_date, :end_date, :cost

  def initialize(record,call_type)
  	fields = record.split(',')
  	if fields[DS_CODE] == 'DS' && fields[DS_TYPE] == 'D' then  # Service Summary and Detail record
  		@service_number = fields[DS_SERVICE]
  		@call_type = call_type.desc(fields[DS_CALL_TYPE])
  		@service_type = fields[DS_SERVICE_TYPE]
  		@units = fields[DS_UNITS]
  		@call_count = fields[DS_CALL_COUNT].to_i
  		@start_date = Time.parse(fields[DS_START_DATE]).strftime('%d/%m/%Y')
  		fields[16] == '' ? @end_date = '' : @end_date = Time.parse(fields[16]).strftime('%d/%m/%Y')
  		@cost = fields[DS_COST].to_f
  	else
  		raise ArgumentError, "Invalid record type - " + fields[DS_CODE], caller
  	end
  end
  
  def to_a
  	call_count = @call_count == 0 ? call_count = "" : call_count = sprintf("%d",@call_count)
  	cost = sprintf("%0.2f",@cost)
  	[@call_type, @service_type, call_count, @units, cost]
  end
end
