class Service

# Header for each phone service
	attr_reader :service_number, :name, :cost_centre, :service_summaries, :call_details
	
  def initialize(service_number, name, cost_centre)
  	@service_number = service_number
  	self.name = name
  	self.cost_centre = cost_centre
  	
  	@service_summaries = Array.new
  	@call_details = Array.new
  end
  
  def name=(name)
  	name ? @name = name : @name = 'Unassigned'
  end 
   
  def cost_centre=(code)
  	code ? @cost_centre = code : @cost_centre = ''
  end 
  
  def add_service_summary(service_summary)
  	@service_summaries << service_summary
  end

	def add_call_detail(call_detail)
  	@call_details << call_detail
  end
  
  def total
  	total = 0.0
  	@service_summaries.each do |service_summary|
  		total += service_summary.cost
  	end
  	total
  end
  
  def service_number_format
  	@service_number[0] == '0' ? "#{@service_number[0,2]} #{@service_number[2,4]} #{@service_number[6,10]}" : @service_number
  end
end