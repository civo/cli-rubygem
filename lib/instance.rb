module CivoCLI
  class Instance < Thor
    desc "list", "list all instances"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      sizes = Civo::Size.all.items
      Civo::Instance.all.items.each do |instance|
        size_name = sizes.detect {|s| s.name == instance.size}&.nice_name
        rows << [instance.id, instance.hostname, size_name, instance.region, instance.public_ip, instance.status]
      end
      puts Terminal::Table.new headings: ['ID', 'Hostname', 'Size', 'Region', 'Public IP', 'Status'], rows: rows
    end

    if CivoCLI::Config.get_meta("admin")
      desc "", ""
      def high_cpu
        # {ENV["CIVO_API_VERSION"] || "1"}/instances/high_cpu"
      end
    end

    desc "show ID/HOSTNAME", "show an instance by ID or hostname"
    def show(id)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id", requires: [:id]
      CivoCLI::Config.set_api_auth
      rows = []
      instance = Civo::Instance.all.items.detect do |instance|
        next unless instance.id == id || instance.hostname == id
        instance
      end

      sizes = Civo::Size.all(all: true).items
      ssh_keys = Civo::SshKey.all.items
      networks = Civo::Network.all.items
      firewalls = Civo::Firewall.all.items

      size = sizes.detect {|s| s.name == instance.size}
      if size
        @size_name = size.description
      end
      @network = networks.detect {|n| n.id == instance.network_id}
      @firewall = firewalls.detect {|fw| fw.id == instance.firewall_id}
  
      puts "                ID : #{instance.id}"
      puts "          Hostname : #{instance.hostname}"
      if instance.reverse_dns
        puts "       Reverse DNS : #{instance.reverse_dns}"
      end
      puts "              Tags : #{instance.tags.join(", ")}"
      puts "              Size : #{@size_name}"
      case instance.status
      when "ACTIVE"
        puts "            Status : #{instance.status.colorize(:green)}"
      when /ING$/
        puts "            Status : #{instance.status.colorize(:orange)}"
      else
        puts "            Status : #{instance.status.colorize(:red)}"
      end
      puts "        Private IP : #{instance.private_ip}"
      puts "         Public IP : #{[instance.pseudo_ip, instance.public_ip].join(" => ")}"
      puts "           Network : #{@network.label} (#{@network.cidr})"
      puts "          Firewall : #{@firewall&.name} (rules: #{@firewall&.rules_count})"
      puts "            Region : #{instance.region}"
      puts "      Initial User : #{instance.initial_user}"
      puts "  Initial Password : #{instance.initial_password}"
      if instance.ssh_key.present?
        key = ssh_keys.detect {|k| k.id == instance.ssh_key}
        puts "           SSH Key : #{key.name} (#{key.fingerprint})"
      end
      puts "      OpenStack ID : #{instance.openstack_server_id}"
      puts "       Template ID : #{instance.template_id}"
      puts "       Snapshot ID : #{instance.snapshot_id}"
      puts ""
      puts "-" * 29 + " NOTES " + "-" * 29
      puts ""
      puts instance.notes
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "", ""
    def create
      # {ENV["CIVO_API_VERSION"] || "1"}/instances", requires: [:hostname, :size, :region],
      # defaults: {public_ip: true, initial_user: "civo"}
    end

    desc "tags ID", "show tags of an instance by ID"
    def tags(id)
      CivoCLI::Config.set_api_auth
       instance = Civo::Instance.all.items.detect do |instance|
        next unless instance.id == id || instance.hostname == id
        instance
      end
      puts "        Tag(s) for #{instance.id}: #{instance.tags.join(", ")}"
      rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "", ""
    def update

    end

    desc "", ""
    def remove
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id", requires: [:id], send_delete_body: true
    end

    desc "reboot ID", "reboots instance with ID entered"
    def reboot(id)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/reboots", requires: [:id]
     CivoCLI::Config.set_api_auth

     instance = Civo::Instance.all.items.detect do |instance|
        next unless instance.id == id || instance.hostname == id
        instance
      end
      
      puts "        Rebooting #{instance.hostname.colorize(:red)}. Use 'civo instance show #{instance.hostname}' to see the current status."
      instance.reboot

        rescue Flexirest::HTTPException => e
        puts e.result.reason.colorize(:red)
        exit 1
    end
    map "hard_reboot" => "reboot"


    desc "soft_reboot ID", "soft-reboots instance with ID entered"
    def soft_reboot(id)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/soft_reboots", requires: [:id]
      CivoCLI::Config.set_api_auth

     instance = Civo::Instance.all.items.detect do |instance|
        next unless instance.id == id || instance.hostname == id
        instance
      end
      
      puts "        Soft-rebooting #{instance.hostname.colorize(:red)}. Use 'civo instance show #{instance.hostname}' to see the current status."
      instance.soft_reboot

        rescue Flexirest::HTTPException => e
        puts e.result.reason.colorize(:red)
        exit 1
    end

    desc "console ID", "outputs a URL for a web-based console for instance with ID"
    def console(id)
      
    end

    desc "stop ID", "shuts down the instance with ID provided"
    def stop(id)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/stop", requires: [:id]
      CivoCLI::Config.set_api_auth

     instance = Civo::Instance.all.items.detect do |instance|
        next unless instance.id == id || instance.hostname == id
        instance
      end
      
      puts "        Stopping #{instance.hostname.colorize(:red)}. Use 'civo instance show #{instance.hostname}' to see the current status."
      instance.stop

        rescue Flexirest::HTTPException => e
        puts e.result.reason.colorize(:red)
        exit 1
    end

    desc "start ID", "starts a stopped instance with ID provided"
    def start(id)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/start", requires: [:id]
      CivoCLI::Config.set_api_auth

     instance = Civo::Instance.all.items.detect do |instance|
        next unless instance.id == id || instance.hostname == id
        instance
      end
      
      puts "        Starting #{instance.hostname.colorize(:green)}. Use 'civo instance show #{instance.hostname}' to see the current status."
      instance.start

        rescue Flexirest::HTTPException => e
        puts e.result.reason.colorize(:red)
        exit 1
    end

    desc "", ""
    def upgrade
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/resize", requires: [:size, :id]
    end

    desc "", ""
    def move_ip
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/ip/:ip", requires: [:ip, :id]
    end

    # desc "", ""
    # def rescue
    #   # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/rescue", requires: [:id]
    # end

    # desc "", ""
    # def unrescue
    #   # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/unrescue", requires: [:id]
    # end

    desc "", ""
    def firewall
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/firewall", requires: [:firewall_id, :id]
    end

    default_task :list
  end
end
