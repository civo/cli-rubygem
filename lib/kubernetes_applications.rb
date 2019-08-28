require 'tempfile'

module CivoCLI
  class KubernetesApplications < Thor
    desc "list", "list all available kubernetes applications"
    option :quiet, type: :boolean, aliases: '-q'
    def list
      CivoCLI::Config.set_api_auth
      if options[:quiet]
        Civo::Kubernetes.applications.items.each do |app|
          puts "#{app.name} (#{app.version}, #{app.category})"
        end
      else
        rows = []
        Civo::Kubernetes.applications.items.each do |app|
          rows << [app.name, app.version, app.category]
        end
        puts Terminal::Table.new headings: ['Name', 'Version', 'Category'], rows: rows
      end
    rescue Flexirest::HTTPForbiddenClientException
      reject_user_access
    end
    map "ls" => "list", "all" => "list"


    desc "show NAME", "show a Kubernetes application by name"
    def show(name)
      CivoCLI::Config.set_api_auth
      rows = []
      app = Finder.detect_app(name)

      puts "              Name : #{app.name}"
      puts "           Version : #{app.version}"
      puts "          Category : #{app.category}"
      puts "        Maintainer : #{app.maintainer}"
      puts "               URL : #{app.url}"
      puts "       Description : #{app.description}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "get" => "show", "inspect" => "show"


    desc "add NAME --cluster=...", "add the marketplace application to a Kubernetes cluster by ID or name"
    option :cluster
    long_desc <<-LONGDESC
      Use --cluster=name to specify part of the ID or name of the cluster to add the application to
    LONGDESC
    def add(name)
      Civo::Kubernetes.verbose!
      Flexirest::Logger.logfile = STDOUT

      CivoCLI::Config.set_api_auth
      app = Finder.detect_app(name)
      cluster = Finder.detect_cluster(options[:cluster])

      Civo::Kubernetes.update(id: cluster.id, applications: app.name)
      puts "Added #{app.name.colorize(:green)} #{app.version} to Kubernetes cluster #{cluster.name.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    default_task :help

    private

    def reject_user_access
      puts "Sorry, this functionality is currently in closed beta and not available to the public yet"
      exit(1)
    end
  end
end
