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
          plans = app.plans&.items
          if plans.present?
            plans = plans.map {|p| p.label}.join(", ")
          else
            plans = "Not applicable"
          end
          dependencies = app.dependencies&.items
          if dependencies.present?
            dependencies = dependencies.map {|d| d}.join(", ")
          else
            dependencies = " "
          end

          rows << [app.name, app.version, app.category, plans, dependencies]
        end
        puts Terminal::Table.new headings: ['Name', 'Version', 'Category', 'Plans', 'Dependencies'], rows: rows
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
      puts "      Dependencies : #{app.dependencies.join(", ")}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "get" => "show", "inspect" => "show"


    desc "add NAME --cluster=...", "add the marketplace application to a Kubernetes cluster by ID or name"
    option :cluster, required: true
    long_desc <<-LONGDESC
      Use --cluster=name to specify part of the ID or name of the cluster to add the application to
    LONGDESC
    def add(name)
      CivoCLI::Config.set_api_auth
      name, plan = name.split(":")
      app = Finder.detect_app(name)
      cluster = Finder.detect_cluster(options[:cluster])
      plans = app.plans&.items

      if app && plans.present? && plan.blank?
        if AskService.available?
          plan = AskService.choose("You requested to add #{app.name} but didn't select a plan. Please choose one...", plans.map(&:label))
          if plan.present?
            puts "Thank you, next time you could use \"#{app.name}:#{plan}\" to choose automatically"
          end
        else
          puts "You need to specify a plan".colorize(:red) + " from those available (#{plans.join(", ")} using the syntax \"#{app.name}:plan\""
          exit 1
        end
      end

      if plan.present?
        Civo::Kubernetes.update(id: cluster.id, applications: "#{app.name}:#{plan}")
      else
        Civo::Kubernetes.update(id: cluster.id, applications: app.name)
      end
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
