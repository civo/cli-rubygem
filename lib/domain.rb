module CivoCLI
  class Domain < Thor
    desc "list", "list all domain records for a domain"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      Civo::DnsDomain.all.items.each do |domain|
        rows << [domain.id, domain.name]
      end
      puts Terminal::Table.new headings: ['ID', 'Name'], rows: rows
    end

    desc "create DOMAIN", "create a new domain name called DOMAIN"
    def create(name)
      CivoCLI::Config.set_api_auth
      domain = Civo::DnsDomain.create(name: name)
      puts "Created a domain called #{name.colorize(:green)} with ID #{domain.id.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "new" => "create"

    desc "remove ID", "remove the domain with ID (or name)"
    def remove(id)
      CivoCLI::Config.set_api_auth
      domain = Civo::DnsDomain.all.items.detect {|key| key.id == id || key.name == id}
      Civo::DnsDomain.remove(id: domain.id)
      puts "Removed the domain #{domain.name.colorize(:green)} with ID #{domain.id.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "delete" => "remove", "rm" => "remove"

    default_task :list

  end
end
