module CivoCLI
  class Instance < Thor
    DEFAULT_SIZE = 'g2.small'
    DEFAULT_REGION = 'lon1'
    DEFAULT_INITIAL_USER = 'civo'
    DEFAULT_PUBLIC_IP = 'true'
    DEFAULT_TEMPLATE = '811a8dfb-8202-49ad-b1ef-1e6320b20497'
    DEFAULT_HOSTNAME = CivoCLI::NameGenerator.create

    desc "list", "list all instances"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      sizes = Civo::Size.all.items
      Civo::Instance.all(per_page: 10_000_000).items.each do |instance|
        size_name = sizes.detect {|s| s.name == instance.size}&.nice_name
        rows << [instance.id, instance.hostname, size_name, instance.region, instance.public_ip, instance.status]
      end
      puts Terminal::Table.new headings: ['ID', 'Hostname', 'Size', 'Region', 'Public IP', 'Status'], rows: rows
    end
    map "ls" => "list", "all" => "list"


    if CivoCLI::Config.get_meta("admin")
      desc "high-cpu", "list high CPU using instances"
      def high_cpu
        CivoCLI::Config.set_api_auth
        instance = detect_instance(id)

        Civo::Instance.high_cpu
      end
    end

    desc "show ID/HOSTNAME", "show an instance by ID or hostname"
    def show(id)
      CivoCLI::Config.set_api_auth
      rows = []
      instance = detect_instance(id)

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
      if instance.ssh_key.present?
        key = ssh_keys.detect { |k| k.id == instance.ssh_key }
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
    map "get" => "show", "inspect" => "show"

    desc "create [--name=HOSTNAME] [...]", "create a new instance with specified hostname and provided options"
    option :name, default: DEFAULT_HOSTNAME, aliases: '--hostname', banner: 'hostname'
    option :size, default: DEFAULT_SIZE, banner: 'instance_size_code'
    option :region, default: DEFAULT_REGION, banner: 'civo_region'
    option :public_ip, default: DEFAULT_PUBLIC_IP, banner: 'true | false | from [instance_id]'
    option :initial_user, default: DEFAULT_INITIAL_USER, banner: 'username', aliases: '--user'
    option :template, banner: 'template_id'
    option :snapshot, banner: 'snapshot_id'
    option :ssh_key, banner: 'ssh_key_id', aliases: '--ssh'
    option :tags, banner: "'tag1 tag2 tag3...'"
    option :wait, type: :boolean
    long_desc <<-LONGDESC
      Create a new instance with hostname (randomly assigned if blank), instance size (default: g2.small),
      \x5template or snapshot ID (default: Ubuntu 18.04 template).
      \x5\x5Optional parameters are as follows:
      \x5 --size=<instance_size> - 'g2.small' if blank. List of sizes and codes to use can be found through `civo sizes`
      \x5 --template=<template_id> - Ubuntu 18.04 if blank. Template_id is from a list of templates at `civo templates`
      \x5 --snapshot=<snapshot_id> - Snapshot ID of a previously-made snapshot. Leave blank if using a template.
      \x5 --public_ip=<true | false | from=instance_id> - 'true' if blank. 'from' requires an existing instance ID configured with a public IP address to move to this new instance.
      \x5 --initial_user=<yourusername> - 'civo' if blank
      \x5 --ssh_key=<ssh_key_id> - for specifying a SSH login key for the default user from saved SSH keys. Random password assigned if blank, visible by calling `civo instance show hostname`
      \x5 --region=<regioncode> from available Civo regions. Randomly assigned if blank
      \x5 --tags=<'tag1 tag2 tag3...'> - space-separated tag(s)
      \x5 --wait - wait for build to complete and show status. Off by default.
    LONGDESC
    def create(*args)
      CivoCLI::Config.set_api_auth

      if !options[:name] && !args
        hostname = CivoCLI::NameGenerator.create
      elsif options[:name]
        hostname = options[:name]
      elsif !options[:name] && args
        hostname = args.join('-')
      end
      if options[:template] && options[:snapshot]
        puts "Please provide either template OR snapshot ID".colorize(:red)
        exit 1
      end

      if !options[:template] && !options[:snapshot]
        options[:template] = DEFAULT_TEMPLATE
      end


      if options[:template]
        @instance = Civo::Instance.create(hostname: hostname, size: options[:size], template: options[:template], public_ip: options[:public_ip], initial_user: options[:initial_user], region: options[:region], ssh_key_id: options[:ssh_key], tags: options[:tags])
      elsif options[:snapshot]
        @instance = Civo::Instance.create(hostname: hostname, size: options[:size], snapshot_id: options[:snapshot], public_ip: options[:public_ip], initial_user: options[:initial_user], region: options[:region], ssh_key_id: options[:ssh_key], tags: options[:tags])
      end

      if options[:wait]
        print "Building new instance #{hostname}: "
        timer = CivoCLI::Timer.new
        timer.start_timer
        spinner = CivoCLI::Spinner.spin(instance: @instance) do |s|
          Civo::Instance.all.items.each do |instance|
            if instance.id == @instance.id && instance.status == 'ACTIVE'
              s[:final_instance] = instance
            end
          end
          s[:final_instance]
        end
        timer.end_timer
        puts "\b Done\nCreated instance #{spinner[:final_instance].hostname.colorize(:green)} - #{spinner[:final_instance].initial_user}@#{spinner[:final_instance].public_ip} in #{Time.at(timer.time_elapsed).utc.strftime("%M min %S sec")}"
      else
        puts "Created instance #{hostname.colorize(:green)}"
      end
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "tags ID/HOSTNAME 'tag1 tag2 tag3...'", "retag instance by ID (input no tags to clear all tags)"
    def tags(id, newtags = nil)
      CivoCLI::Config.set_api_auth
      instance = detect_instance(id)

      Civo::Instance.tags(id: instance.id, tags: newtags)
      puts "Updated tags on #{instance.hostname.colorize(:green)}. Use 'civo instance show #{instance.hostname}' to see the current tags.'"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "update ID/HOSTNAME [--name] [--notes]", "update details of instance"
    option :name
    option :notes
    long_desc <<-LONGDESC
      Use --name=new_host_name, --notes='free text notes string' to specify the details you wish to update.
    LONGDESC
    def update(id)
      CivoCLI::Config.set_api_auth
      instance = detect_instance(id)

      if options[:name]
        Civo::Instance.update(id: instance.id, hostname: options[:name])
        puts "Instance #{instance.id} now named #{options[:name].colorize(:green)}"
      end
      if options[:notes]
        Civo::Instance.update(id: instance.id, notes: options[:notes])
        puts "Instance #{instance.id} notes are now: #{options[:notes].colorize(:green)}"
      end
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "remove ID/HOSTNAME", "removes an instance with ID/hostname entered (use with caution!)"
    def remove(id)
      CivoCLI::Config.set_api_auth
      instance = detect_instance(id)

      puts "Removing instance #{instance.hostname.colorize(:red)}"
      instance.remove
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "delete" => "remove"

    desc "reboot ID/HOSTNAME", "reboots instance with ID/hostname entered"
    def reboot(id)
      CivoCLI::Config.set_api_auth

      instance = detect_instance(id)
      puts "Rebooting #{instance.hostname.colorize(:red)}. Use 'civo instance show #{instance.hostname}' to see the current status."
      instance.reboot
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "hard-reboot" => "reboot"

    desc "soft-reboot ID/HOSTNAME", "soft-reboots instance with ID entered"
    def soft_reboot(id)
      CivoCLI::Config.set_api_auth

      instance = detect_instance(id)
      puts "Soft-rebooting #{instance.hostname.colorize(:red)}. Use 'civo instance show #{instance.hostname}' to see the current status."
      instance.soft_reboot
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "console ID/HOSTNAME", "outputs a URL for a web-based console for instance with ID provided"
    def console(id)
      CivoCLI::Config.set_api_auth
      instance = detect_instance(id)
      puts "Access #{instance.hostname.colorize(:green)} at #{instance.console.url}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "stop ID/HOSTNAME", "shuts down the instance with ID provided"
    def stop(id)
      CivoCLI::Config.set_api_auth
      instance = detect_instance(id)
      puts "Stopping #{instance.hostname.colorize(:red)}. Use 'civo instance show #{instance.hostname}' to see the current status."
      Civo::Instance.stop(id: instance.id)
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "start ID/HOSTNAME", "starts a stopped instance with ID provided"
    def start(id)
      CivoCLI::Config.set_api_auth

      instance = detect_instance(id)
      puts "Starting #{instance.hostname.colorize(:green)}. Use 'civo instance show #{instance.hostname}' to see the current status."
      instance.start
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "upgrade ID/HOSTNAME new-size", "Upgrade instance with ID to size provided (see civo sizes for size names)"
    def upgrade(id, new_size)
      CivoCLI::Config.set_api_auth

      instance = detect_instance(id)

      Civo::Instance.upgrade(id: instance.id, size: new_size)
      puts "Resizing #{instance.hostname.colorize(:green)} to #{new_size.colorize(:red)}. Use 'civo instance show #{instance.hostname}' to see the current status."
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "move-ip ID/HOSTNAME IP_Address", "move a public IP_Address to target instance"
    def move_ip(id, ip_address)
      CivoCLI::Config.set_api_auth

      instance = detect_instance(id)

      Civo::Instance.move_ip(id: instance.id, ip: ip_address)
      puts "Moved public IP #{ip_address} to instance #{instance.hostname}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "firewall ID/HOSTNAME firewall_id", "set instance with ID/HOSTNAME to use firewall with firewall_id"
    def firewall(id, firewall_id)
      CivoCLI::Config.set_api_auth

      instance = detect_instance(id)

      Civo::Instance.firewall(id: instance.id, firewall_id: firewall_id)
      puts "Set #{instance.hostname.colorize(:green)} to use firewall '#{firewall_id.colorize(:yellow)}'"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "public_ip ID/HOSTNAME", "Show public IP of ID/hostname"
    option :quiet, type: :boolean, aliases: '-q'
    def public_ip(id)
      CivoCLI::Config.set_api_auth
  
      instance = detect_instance(id)
      unless instance.public_ip.nil?
        if options[:quiet]
          puts instance.public_ip
        else
          puts "The public IP for #{instance.hostname.colorize(:green)} is #{instance.public_ip.colorize(:green)}"
        end
      else 
        puts "Error: Instance has no public IP"
        exit 2
      end

    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "ip" => "public_ip"


    desc "password ID/HOSTNAME", "Show the default user password for instance with ID/HOSTNAME"
    option :quiet, type: :boolean, aliases: '-q'
    def password(id)
      CivoCLI::Config.set_api_auth
      instance = detect_instance(id)
      if options[:quiet]
        puts instance.initial_password
      else
        puts "The password for user #{instance.initial_user.colorize(:green)} on #{instance.hostname.colorize(:green)} is #{instance.initial_password.colorize(:green)}"
      end
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1  
    end
  
    default_task :help

    private

    def detect_instance(id)
      result = []
      Civo::Instance.all(per_page: 10_000_000).items.each do |instance|
        result << instance
      end
      result.select! { |instance| instance.hostname.include?(id) || instance.id.include?(id) }

      if result.count.zero?
        puts "No instances found for '#{id}'. Please check your query."
        exit 1
      elsif result.count > 1
        puts "Multiple possible instances found for '#{id}'. Please try with a more specific query."
        exit 1
      else
        result[0]
      end
    end
  end
end
