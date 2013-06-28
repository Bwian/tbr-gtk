class Services

# Services container
	
  def initialize
  	@services = Hash.new
  end
  
  def service(service_number)
  	if !@services.include?(service_number)
  		@services[service_number] = Service.new(service_number,nil,nil) 
  	end
  	@services[service_number]
  end
  
  def size
  	@services.size
  end
  
  def each(&blk)
  	@services.each_value(&blk)
  end 
  
  def delete(service_number)
  	@services.delete(service_number)
  end
  
  def name 
  	"Unassigned"   # for when Services is acting like a Group
  end
end