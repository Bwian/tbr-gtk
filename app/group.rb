class Group

# Phone services grouped for
	attr_reader :name
	
  def initialize(name)
  	@name = name
  	
  	@services = Array.new
  end
    
  def add_service(service)
  	@services << service
  end

	def size
  	@services.size
  end
  
	def each(&blk)
  	@services.each(&blk)
  end 
end