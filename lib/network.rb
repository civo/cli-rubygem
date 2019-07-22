module CivoCLI
  class Network < Thor
    desc "list", "list all networks"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      Civo::Network.all.items.each do |network|
        if network.default
          rows << [network.id, network.label, network.cidr, "<====="]
        else
          rows << [network.id, network.label, network.cidr, ""]
        end
      end
      puts Terminal::Table.new headings: ['ID', 'Label', 'CIDR', 'Default?'], rows: rows
    end
    map "ls" => "list", "all" => "list"


    desc "create LABEL", "create a new private network called LABEL"
    def create(label)
      CivoCLI::Config.set_api_auth
      network = Civo::Network.create(label: label)
      puts "Create a private network called #{label.colorize(:green)} with ID #{network.id.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "new" => "create"

    desc "remove ID", "remove the network ID"
    def remove(id)
      CivoCLI::Config.set_api_auth
      network = Civo::Network.all.items.detect {|key| key.id == id}
      Civo::Network.remove(id: id)
      puts "Removed the network #{network.label.colorize(:green)} with ID #{network.id.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "delete" => "remove", "rm" => "remove"

    default_task :help

  end
end
