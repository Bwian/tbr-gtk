require_relative 'services'
require_relative 'call_type'
require_relative 'service'
require_relative 'service_summary'
require_relative 'call_detail'
require_relative 'group'
require_relative 'groups'
require_relative 'create_files'
require_relative 'parse_files'
require_relative 'log_it'

class ProcessBills

  UNASSIGNED	= 'Unassigned'  
  
  def initialize
    @log = LogIt.instance
    @textview = nil
  end
  
  def run (config_file,bill_file)
    @log.info("Starting Telstra Billing Data Extract")

    @log.info("Extracting Call Types from #{bill_file}")
    call_type = CallType.new
    call_type.load(bill_file)

    services = Services.new
    groups = Groups.new

    @log.info("Mapping services from #{config_file}")
    ParseFiles.map_services(groups,services,config_file)
    @log.info("Extracting billing data from #{bill_file}")
    invoice_date = ParseFiles.parse_bill_file(services,call_type,bill_file)

    @log.info("Building Unassigned group")
    group = groups.group(UNASSIGNED)
    services.each do |service|
    	group.add_service(service) if service.name == UNASSIGNED
    end

    cf = CreateFiles.new(invoice_date)
    @log.info("Creating group summaries")
    groups.each do |group|
    	cf.group_summary(group)
    end

    @log.info("Creating service details")
    services.each do |service|
    	cf.call_details(service)
    end

    @log.info("Creating service totals summary")
    cf.service_totals(services)

    CreateFiles.archive(bill_file)
    
    @log.info("Telstra Billing Data Extract completed.") 
  end 
end