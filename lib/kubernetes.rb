module CivoCLI
  class Kubernetes < Thor
    desc "list", "list all kubernetes clusters"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      Civo::Kubernetes.all.items.each do |cluster|
        rows << [cluster.id, cluster.name, cluster.num_target_nodes, cluster.target_nodes_size, cluster.status]
      end
      puts Terminal::Table.new headings: ['ID', 'Name', '# Nodes', 'Size', 'Status'], rows: rows
    rescue Flexirest::HTTPForbiddenClientException
      reject_user_access
    end

    desc "show ID/NAME", "show a Kubernetes cluster by ID or name"
    def show(id)
      CivoCLI::Config.set_api_auth
      rows = []
      cluster = detect_cluster_id(id)

      puts "                ID : #{cluster.id}"
      puts "              Name : #{cluster.name}"
      puts "           # Nodes : #{cluster.num_target_nodes}"
      puts "              Size : #{cluster.target_nodes_size}"
      case cluster.status
      when "ACTIVE"
        puts "            Status : #{cluster.status.colorize(:green)}"
      when /ING$/
        puts "            Status : #{cluster.status.colorize(:orange)}"
      else
        puts "            Status : #{cluster.status.colorize(:red)}"
      end
      puts "           Version : #{cluster.kubernetes_version}"
      puts "      API Endpoint : #{cluster.kubeconfig[/https:\/\/(\d+.)*:6443/]}"
      #<Civo::Kubernetes id: "9f1cf43c-a924-468f-baa7-38dbe0e98ff0", name: "chris-edward", version: "1", status: "ACTIVE", num_target_nodes: 3, target_nodes_size: "g2.medium", built_at: "2019-06-27 16:56:25", kubeconfig: "apiVersion: v1\nclusters:\n- cluster:\n    certificate...", kubernetes_version: "0.6.1", created_at: "2019-06-27 16:52:10", instances: #<Flexirest::ResultIterator:0x00007fc43847d958 @_status=nil, @_headers=nil, @items=[#<Civo::Kubernetes hostname: "k8s-node-acf8", size: "g2.medium", region: "lon1", created_at: "2019-06-27 16:52:11", status: "ACTIVE", firewall_id: "fdf99ced-e257-4ddf-9c81-da81a1dea4ff", public_ip: "185.136.234.35">, #<Civo::Kubernetes hostname: "k8s-node-3615", size: "g2.medium", region: "lon1", created_at: "2019-06-27 16:52:11", status: "ACTIVE", firewall_id: "fdf99ced-e257-4ddf-9c81-da81a1dea4ff", public_ip: "185.136.232.85">, #<Civo::Kubernetes hostname: "k8s-master-4f46", size: "g2.medium", region: "lon1", created_at: "2019-06-27 16:52:11", status: "ACTIVE", firewall_id: "fdf99ced-e257-4ddf-9c81-da81a1dea4ff", public_ip: "185.136.232.240">]>>

      puts ""
      rows = []
      cluster.instances.each do |instance|
        rows << [instance.hostname, instance.public_ip, instance.status]
      end
      puts Terminal::Table.new headings: ['Name', 'IP', 'Status'], rows: rows
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "config ID/NAME", "get the ~/.kube/config for a Kubernetes cluster by ID or name"
    def config(id)
      CivoCLI::Config.set_api_auth
      rows = []
      cluster = detect_cluster_id(id)
      puts cluster.kubeconfig
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "create [NAME] [...]", "create a new kubernetes cluster with the specified name and provided options"
    option :size, default: 'g2.medium', banner: 'size'
    option :nodes, default: '3', banner: 'node_count'
    option :wait, type: :boolean
    long_desc <<-LONGDESC
      Create a new Kubernetes cluster with name (randomly assigned if blank), instance size (default: g2.medium),
      \x5\x5Optional parameters are as follows:
      \x5 --size=<instance_size> - 'g2.medium' if blank. List of sizes and codes to use can be found through `civo sizes`
      \x5 --nodes=<count> - '3' if blank
      \x5 --wait - wait for build to complete and show status. Off by default.
    LONGDESC
    def create(name = CivoCLI::NameGenerator.create, *args)
      CivoCLI::Config.set_api_auth
      @cluster = Civo::Kubernetes.create(name: name, target_nodes_size: options[:size], num_target_nodes: options[:nodes])

      if options[:wait]
        print "Building new Kubernetes cluster #{name.colorize(:green)}: "

        spinner = CivoCLI::Spinner.spin(instance: @instance) do |s|
          Civo::Kubernetes.all.items.each do |cluster|
            if cluster.id == @cluster.id && cluster.status == 'ACTIVE'
              s[:final_cluster] = cluster
            end
          end
          s[:final_cluster]
        end

        puts "\b Done\nCreated cluster #{spinner[:final_cluster].name.colorize(:green)}"
      else
        puts "Created instance #{name.colorize(:green)}"
      end
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
      instance = detect_instance_id(id)

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

    desc "remove ID/NAME", "removes an entire Kubernetes cluster with ID/name entered (use with caution!)"
    def remove(id)
      CivoCLI::Config.set_api_auth
      cluster = detect_cluster_id(id)

      puts "Removing Kubernetes cluster #{cluster.name.colorize(:red)}"
      cluster.remove
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "reboot ID/HOSTNAME", "reboots instance with ID/hostname entered"
    def reboot(id)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/reboots", requires: [:id]
      CivoCLI::Config.set_api_auth

      instance = detect_instance_id(id)
      puts "Rebooting #{instance.hostname.colorize(:red)}. Use 'civo instance show #{instance.hostname}' to see the current status."
      instance.reboot
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "hard-reboot" => "reboot"

    desc "soft-reboot ID/HOSTNAME", "soft-reboots instance with ID entered"
    def soft_reboot(id)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/soft_reboots", requires: [:id]
      CivoCLI::Config.set_api_auth

      instance = detect_instance_id(id)
      puts "Soft-rebooting #{instance.hostname.colorize(:red)}. Use 'civo instance show #{instance.hostname}' to see the current status."
      instance.soft_reboot
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "console ID/HOSTNAME", "outputs a URL for a web-based console for instance with ID provided"
    def console(id)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/console", requires: [:id]
      CivoCLI::Config.set_api_auth
      instance = detect_instance_id(id)
      puts "Access #{instance.hostname.colorize(:green)} at #{instance.console.url}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "stop ID/HOSTNAME", "shuts down the instance with ID provided"
    def stop(id)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/stop", requires: [:id]
      CivoCLI::Config.set_api_auth
      instance = detect_instance_id(id)
      puts "Stopping #{instance.hostname.colorize(:red)}. Use 'civo instance show #{instance.hostname}' to see the current status."
      Civo::Instance.stop(id: instance.id)
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "start ID/HOSTNAME", "starts a stopped instance with ID provided"
    def start(id)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/start", requires: [:id]
      CivoCLI::Config.set_api_auth

      instance = detect_instance_id(id)
      puts "Starting #{instance.hostname.colorize(:green)}. Use 'civo instance show #{instance.hostname}' to see the current status."
      instance.start
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "upgrade ID/HOSTNAME new-size", "Upgrade instance with ID to size provided (see civo sizes for size names)"
    def upgrade(id, new_size)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/resize", requires: [:size, :id]
      CivoCLI::Config.set_api_auth

      instance = detect_instance_id(id)

      Civo::Instance.upgrade(id: instance.id, size: new_size)
      puts "Resizing #{instance.hostname.colorize(:green)} to #{new_size.colorize(:red)}. Use 'civo instance show #{instance.hostname}' to see the current status."
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "move-ip ID/HOSTNAME IP_Address", "move a public IP_Address to target instance"
    def move_ip(id, ip_address)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/ip/:ip", requires: [:ip, :id]
      CivoCLI::Config.set_api_auth

      instance = detect_instance_id(id)

      Civo::Instance.move_ip(id: instance.id, ip: ip_address)
      puts "Moved public IP #{ip_address} to instance #{instance.hostname}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    # desc "", ""
    # def rescue
    #   # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/rescue", requires: [:id]
    # end

    # desc "", ""
    # def unrescue
    #   # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/unrescue", requires: [:id]
    # end

    desc "firewall ID/HOSTNAME firewall_id", "set instance with ID/HOSTNAME to use firewall with firewall_id"
    def firewall(id, firewall_id)
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/firewall", requires: [:firewall_id, :id]
      CivoCLI::Config.set_api_auth

      instance = detect_instance_id(id)

      Civo::Instance.firewall(id: instance.id, firewall_id: firewall_id)
      puts "Set #{instance.hostname.colorize(:green)} to use firewall '#{firewall_id.colorize(:yellow)}'"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    default_task :list

    private

    def detect_cluster_id(id)
      result = []
      Civo::Kubernetes.all.items.each do |cluster|
        result << cluster
      end
      result.select! { |cluster| cluster.name.include?(id) }

      if result.count.zero?
        puts "No Kubernetes clusters found for '#{id}'. Please check your query."
        exit 1
      elsif result.count > 1
        puts "Multiple possible Kubernetes clusters found for '#{id}'. Please try with a more specific query."
        exit 1
      else
        result[0]
      end
    end

    def reject_user_access
      puts "Sorry, this functionality is currently in closed beta and not available to the public yet"
      exit(1)
    end
  end
end
