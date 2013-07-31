require_relative 'group'

class Groups

# Groups container
	
  def initialize
  	@groups = Hash.new
  end
  
  def group(name)
  	if !@groups.include?(name)
  		@groups[name] = Group.new(name) 
  	end
  	@groups[name]
  end
  
  def size
  	@groups.size
  end 
  
  def each(&blk)
  	Hash[@groups.sort].each_value(&blk)
  end 
end