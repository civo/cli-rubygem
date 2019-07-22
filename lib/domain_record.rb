module CivoCLI
  class DomainRecord < Thor

    desc "list DOMAIN_ID", "list all entries for DOMAIN_ID (or name)"
    def list(domain_id)
      CivoCLI::Config.set_api_auth
      domain = Civo::DnsDomain.all.items.detect {|key| key.id == domain_id || key.name == domain_id}

      rows = []
      Civo::DnsRecord.all(domain_id: domain.id).items.each do |record|
        value = (record.value.length > 20 ? record.value[0, 17] + "..." : record.value)
        rows << [record.id, record.type.upcase, "#{record.name}.#{domain.name.colorize(:light_black)}", value, record.ttl, record.priority]
      end
      puts Terminal::Table.new headings: ['ID', 'Type', 'Name', 'Value', 'TTL', 'Priority'], rows: rows
    end
    map "ls" => "list", "all" => "list"


    desc "show RECORD_ID", "show full information for record RECORD_ID (or full DNS name)"
    def show(record_id)
      CivoCLI::Config.set_api_auth
      Civo::DnsDomain.all.items.each do |domain|
        @domain = domain
        @record = Civo::DnsRecord.all(domain_id: domain.id).detect {|key| key.id == record_id || (key.domain_id == domain.id && key.name == record_id.gsub(/\.#{domain.name}$/, '')) }
        break if @record
      end
      puts "               ID: #{@record.id}"
      puts "             Type: #{@record.type.upcase}"
      puts "             Name: #{@record.name}.#{@domain.name.colorize(:light_black)}"
      puts "              TTL: #{@record.ttl}"
      puts "         Priority: #{@record.priority}"
      puts ""
      puts "-" * 29 + "VALUE" + "-" * 29
      puts @record.value
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "get" => "show", "inspect" => "show"

    option :priority, type: :string, desc: "The priority for MX records", aliases: ["-p"], banner: "PRIORITY"
    option :ttl, type: :string, desc: "The Time-To-Live for this record", aliases: ["-t"], banner: "TTL"
    desc "create RECORD TYPE VALUE", "create a new domain record called RECORD TYPE(a/alias, cname/canonical, mx/mail, txt/text) VALUE"
    def create(name, type, value)
      CivoCLI::Config.set_api_auth
      domain, part = find_domain(name)
      if domain
        type = case(type.downcase)
        when "cname", "canonical"
          "cname"
        when "mx", "mail"
          "mx"
        when "txt", "text"
          "txt"
        else
          "a"
        end.upcase
        out = "Created #{type.colorize(:green)} record #{part.colorize(:green)} for #{domain.name.colorize(:green)}"
        if options[:ttl] && options[:ttl] != ""
          out += " with a TTL of #{options[:ttl].colorize(:green)} seconds"
          if options[:priority] && options[:priority] != ""
            out += " and"
          end
        end
        if options[:priority] && options[:priority] != ""
          out += " with a priority of #{options[:priority].colorize(:green)}"
        end
        options[:ttl] ||= 600
        options[:priority] ||= 0

        record = Civo::DnsRecord.create(type: type, domain_id: domain.id, name: part, value: value, priority: options[:priority], ttl: options[:ttl])
        puts record.inspect
        puts "#{out} with ID #{record.id.colorize(:green)}"
      else
        puts "Unable to find the domain name for #{name}".colorize(:red)
      end
    rescue Flexirest::HTTPException => e
      puts e.inspect
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "new" => "create"

    desc "remove ID", "remove the domain record with ID"
    def remove(id)
      CivoCLI::Config.set_api_auth
      Civo::DnsDomain.all.items.each do |d|
        Civo::DnsRecord.all(domain_id: d.id).items.each do |r|
          if r.id == id
            Civo::DnsRecord.remove(domain_id: d.id, id: r.id)
            puts "Removed the record #{r.name.colorize(:green)} record with ID #{r.id.colorize(:green)}"
          end
        end
      end
    rescue Flexirest::HTTPException => e
      puts e.result&.reason&.colorize(:red)
      exit 1
    end
    map "delete" => "remove", "rm" => "remove"

    default_task :help

    private

    def find_domain(record)
      domain = nil
      part = nil
      Civo::DnsDomain.all.items.each do |d|
        if record.end_with? d.name
          domain = d
          part = record.gsub(".#{d.name}", "")
          break
        end
      end
      [domain, part]
    end

  end
end
