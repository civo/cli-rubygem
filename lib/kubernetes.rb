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
      cluster = detect_cluster(id)

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
      puts "      API Endpoint : #{cluster.api_endpoint}"

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
      cluster = detect_cluster(id)
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

        puts "\b Done\nCreated Kubernetes cluster #{spinner[:final_cluster].name.colorize(:green)}"
      else
        puts "Created Kubernetes cluster #{name.colorize(:green)}"
      end
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "rename ID/NAME [--name]", "rename Kubernetes cluster"
    option :name
    long_desc <<-LONGDESC
      Use --name=new_host_name to specify the new name you wish to use.
    LONGDESC
    def rename(id)
      CivoCLI::Config.set_api_auth
      cluster = detect_cluster(id)

      if options[:name]
        Civo::Kubernetes.update(id: cluster.id, name: options[:name])
        puts "Kubernetes cluster #{cluster.id} is now named #{options[:name].colorize(:green)}"
      end
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "scale ID/NAME [--nodes]", "rescale the Kubernetes cluster to a new node count"
    option :nodes
    long_desc <<-LONGDESC
      Use --nodes=count to specify the new number of nodes to run.
    LONGDESC
    def scale(id)
      CivoCLI::Config.set_api_auth
      cluster = detect_cluster(id)

      if options[:nodes]
        Civo::Kubernetes.update(id: cluster.id, num_target_nodes: options[:nodes])
        puts "Kubernetes cluster #{cluster.name.colorize(:green)} will now have #{options[:nodes].colorize(:green)} nodes"
      end
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "rescale" => "scale"

    desc "remove ID/NAME", "removes an entire Kubernetes cluster with ID/name entered (use with caution!)"
    def remove(id)
      CivoCLI::Config.set_api_auth
      cluster = detect_cluster(id)

      puts "Removing Kubernetes cluster #{cluster.name.colorize(:red)}"
      cluster.remove
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "delete" => "remove", "destroy" => "remove"

    default_task :list

    private

    def detect_cluster(id)
      result = []
      Civo::Kubernetes.all.items.each do |cluster|
        result << cluster
      end
      result.select! { |cluster| cluster.name.include?(id) || cluster.id.include?(id) }

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
