module CivoCLI
  class Firewall < Thor
    desc "create firewall_name", "create a new firewall"
    def create(firewall_name)
      # {ENV["CIVO_API_VERSION"] || "1"}/firewalls"
      CivoCLI::Config.set_api_auth
    
      Civo::Firewall.create(name: firewall_name)
      puts "        Created firewall #{firewall_name.colorize(:green)}"
      
      rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "list", "lists all firewalls"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      Civo::Firewall.all.items.each do |element|
        rows << [element.id, element.name, element.rules_count, element.instances_count]
      end
      puts Terminal::Table.new headings: ['ID', 'Name', 'No. of Rules', 'instances using'], rows: rows
    end

    desc "", ""
    def remove

    end

    desc "", ""
    def new_rule

    end

    desc "", ""
    def list_rules

    end

    desc "", ""
    def delete_rule

    end
  end
end
