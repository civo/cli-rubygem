module CivoCLI
  class Firewall < Thor
    desc "create firewall_name", "Create a new firewall"
    def create(firewall_name)
      # {ENV["CIVO_API_VERSION"] || "1"}/firewalls"
      CivoCLI::Config.set_api_auth
    
      Civo::Firewall.create(name: firewall_name)
      puts "        Created firewall #{firewall_name.colorize(:green)}"
      
      rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "list", "Lists all firewalls"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      Civo::Firewall.all.items.each do |element|
        rows << [element.id, element.name, element.rules_count, element.instances_count]
      end
      puts Terminal::Table.new headings: ['ID', 'Name', 'No. of Rules', 'instances using'], rows: rows

      rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "remove firewall_ID", "Removes a firewall with Firewall ID provided"
    def remove(firewall_ID)
      CivoCLI::Config.set_api_auth
      
      Civo::Firewall.remove(id: firewall_ID)
      puts "        Removed firewall #{firewall_ID.colorize(:red)}"

      rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "new_rule", "Create new rule on firewall firewall_name called rule_name with required arguments"
    option :firewall_id, :required => true
    option :protocol, :default => 'tcp'
    option :start_port, :required => true
    option :end_port
    option :cidr, :default => '0.0.0.0/0'
    option :direction, :default => 'inbound'
    option :label
    def new_rule
      CivoCLI::Config.set_api_auth

      if !options[:end_port]
        Civo::FirewallRule.create(firewall_id: options[:firewall_id], start_port: options[:start_port], end_port: options[:start_port], cidr: options[:cidr], direction: options[:direction], label: options[:label])
      end

      if options[:end_port]
        Civo::FirewallRule.create(firewall_id: options[:firewall_id], start_port: options[:start_port], end_port: options[:end_port], cidr: options[:cidr], direction: options[:direction], label: options[:label])
      end

      puts "        New rule" + (options[:label].nil? ? "" : " #{options[:label].colorize(:green)}") + " created"
 
      rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "list_rules firewall_id", "Lists all active rules for firewall ID provided"
    def list_rules(firewall_id)
      CivoCLI::Config.set_api_auth
      
      rules = Civo::FirewallRule.all(firewall_id: firewall_id)
      rows = []
      rules.each do |rule|
        rows << [rule.id, rule.protocol, rule.start_port, rule.end_port, rule.cidr.items.join(", "), rule.label]
      end
      puts Terminal::Table.new title: "Firewall rules for #{firewall_id}", headings: ['ID', 'Protocol', 'Start Port', 'End Port', 'CIDR', 'Label'], rows: rows
      
      rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "delete_rule firewall_id rule_id", "Deletes rule with rule_id from firewall with firewall_id"
    def delete_rule(firewall_id, rule_id)
      # "/v2/firewalls/:firewall_id/rules/:id", required: [:firewall_id, :id]
      CivoCLI::Config.set_api_auth

      Civo::FirewallRule.remove(firewall_id: firewall_id, id: rule_id)
      puts "        Removed Firewall rule #{rule_id.colorize(:red)}"
      
      rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
  end
end
