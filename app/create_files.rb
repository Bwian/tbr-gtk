require 'prawn'
require 'prawn/measurement_extensions'
require 'time'
require 'fileutils'
require_relative 'group'
require_relative 'service'
require_relative 'log_it'
require_relative 'configure'

class CreateFiles
	ROW_COLOUR_ODD    = "EBD6D6"
	ROW_COLOUR_EVEN   = "FFFFFF"
	ROW_COLOUR_HEAD   = "D6ADAD"
	UCB_GREEN				  = "666633"
	UCB_RED					  = "993333"
	
# Header for each phone service
	attr_reader :invoice_month, :dir_root
	
  def initialize(invoice_date,replace)
    @invoice_month  = Time.parse(invoice_date).strftime('%B %Y')
  	@dir_root       = "#{Configure.instance.data}/#{invoice_date[0..5]}"	
  	@dir_summaries  = "#{@dir_root}/summaries"
  	@dir_details    = "#{@dir_root}/details"
    
  	FileUtils.rm_rf(@dir_root) if replace
    raise IOError, "#{dir_full_root} already exists" if File.exist?(@dir_root)
  	
    Dir.mkdir(@dir_root) 	
  	Dir.mkdir(@dir_summaries)
  	Dir.mkdir(@dir_details)
  end
  
  def group_summary(group)
  	create_group_summary(group)
  end
  
  def call_details(service)
  	create_call_details(service)	
  end
  
  def service_totals(services)
  	create_service_totals(services)
  end
  
  def dir_full_root
    File.realdirpath(@dir_root)
  end
  
  def self.archive(bill_file)
    to_file = "#{Configure.instance.archive}/#{Time.now.strftime('%Y%m%d.%H%M%S.csv')}"
    FileUtils.mv(bill_file,to_file)
    LogIt.instance.info("Billing file archived to #{File.realdirpath(to_file)}")
  end
  
  private
  
  def header(pdf,heading,name)
  	pdf.table([
			[{:image => "./images/logo.jpg", :scale => 0.1, :rowspan => 2}, 
			{:content => heading, :rowspan => 2, :text_color => UCB_GREEN, :size => 20, :font_style => :bold },
			{:content => @invoice_month, :text_color => UCB_RED, :font_style => :bold}],
			[{:content => name, :text_color => UCB_RED, :font_style => :bold}]
		], :column_widths => [130,260,130]) do
			cells.padding = 0
			cells.borders = []
			column(2).style(:align => :right)
			column(1).style(:align => :center)
		end
  end
  
  def footer(pdf)
  	page_no = '<page> of <total>'
		pdf.number_pages(page_no, {:at => [0,0], :align => :center})	
  end
  
  def create_group_summary(group)
  	fname = "#{@dir_summaries}/#{group.name} - #{@invoice_month}.pdf"
  	Prawn::Document.generate(fname, :page_layout => :portrait, :page_size => "A4") do |pdf|
  		header(pdf,"Telstra Billing Summary","Manager: #{group.name}")
  		group.each do |service| 
				format_summary(pdf,service)
			end
			footer(pdf)
  	end
  end
  
  def create_call_details(service)
  	fname = "#{@dir_details}/#{service.service_number} - #{@invoice_month}.pdf"
  	
  	data = [['Start','','Type','Destination','Area','Duration','Cost']]
		service.call_details.each do |cd|
			data << [cd.start_date, cd.start_time, cd.call_type, cd.destination, cd.area, cd.duration, sprintf("%.2f",cd.cost)]
		end
			
  	Prawn::Document.generate(fname, :page_layout => :portrait, :page_size => "A4") do |pdf|
  		header(pdf,"Telstra Billing Details","")
			format_summary(pdf,service)
			
			pdf.font_size 10
			pdf.move_down 18
			
			pdf.table(data, 
				:row_colors => [ROW_COLOUR_EVEN, ROW_COLOUR_ODD],
				:header => :true, 
				:column_widths => [55,45,155,100,80,45,40]) do
				cells.padding = 2
				cells.borders = []
	
				row(0).font_style = :bold
				row(0).background_color = ROW_COLOUR_HEAD
				column(6).style(:align => :right)
			end
			
			footer(pdf)
		end
  end
  
  def create_service_totals(services)
  	fname = "#{@dir_root}/Service Totals - #{@invoice_month}.pdf"
  	
  	grand_total = 0.0
  	data = [["Number", "Name", "CC", "Total"]]
  	services.each do |service|
  		data << [service.service_number_format, service.name, service.cost_centre, sprintf("%.2f", service.total)]
  		grand_total += service.total	
  	end
  	data << ['','','Grand Total:', sprintf('$%8.2f',grand_total)]
  	
  	Prawn::Document.generate(fname, :page_layout => :portrait, :page_size => "A4") do |pdf|
  		header(pdf,"Telstra Service Totals","")
  		
  		pdf.font_size 10
			pdf.move_down 18
			
			pdf.table(data, 
				:row_colors => [ROW_COLOUR_EVEN, ROW_COLOUR_ODD],
				:header => :true, 
				:column_widths => [100,270,100,50]) do
				cells.padding = 2
				cells.borders = []
	
				last = data.size - 1
				row([0,last]).font_style = :bold
				row([0,last]).background_color = ROW_COLOUR_HEAD
				column(3).style(:align => :right)
			end
			
			footer(pdf)
  	end
  end
  
  def format_summary(pdf,service)
		total = 0.0
		data = [["Call Type", "Service", "", "", "Cost"]]
		service.service_summaries.each do |ss|
			data << ss.to_a
			total += ss.cost
		end
		data << ['','','','Total:', sprintf('$%7.2f',total)]
		
		pdf.group do
			pdf.font_size 10
			pdf.move_down 18
			pdf.text("#{service.service_number_format} - #{service.name}", :style => :bold, :align => :center)
			pdf.move_down 6
			
			pdf.table(data, 
				:row_colors => [ROW_COLOUR_ODD, ROW_COLOUR_EVEN], 
				:column_widths => [220,150,50,50,50]) do
				cells.padding = 2
				cells.borders = []
	
				last = data.size - 1
				row([0,last]).font_style = :bold
				row([0,last]).background_color = ROW_COLOUR_HEAD
				column([2,4]).style(:align => :right)
			end
		end
  end

end
