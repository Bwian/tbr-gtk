class CallType

  def initialize
    @types = Hash.new
  end
  
  def load(filename)
  	file = File.new(filename)
  	@types = Hash.new
  	file.each_line do |line|
  		fields = line.split(',')
  		@types[fields[1]] = fields[3] if fields[0] == 'TC'	
  	end
  end
  
  def size
  	@types.size
  end
  
  def desc(code)
  	@types[code] ? @types[code] : "Unknown service type - " + code
  end
end
