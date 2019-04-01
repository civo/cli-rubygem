module CivoCLI
  class Blueprint < Thor
    desc "list", "list all blueprints"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      Civo::Blueprint.all.items.each do |blueprint|
        rows << [blueprint.id, blueprint.name, blueprint.template_id, blueprint.version, blueprint.last_build_ended_at]
      end
      puts Terminal::Table.new headings: ['ID', 'Name', 'Template ID', 'Version', "Last built"], rows: rows
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "show ID", "show the details for a single blueprint"
    def show(id)
      CivoCLI::Config.set_api_auth
      blueprint = Civo::Blueprint.all.detect {|b| b.id == id }
      puts "                ID : #{blueprint.id}"
      puts "              Name : #{blueprint.name}"
      puts "       Template ID : #{blueprint.template_id}"
      puts "           Version : #{blueprint.version}"
      puts "Last Build Started : #{blueprint.last_build_started_at&.strftime("%-d %B %Y, %H:%M:%S")}"
      puts "  Last Build Ended : #{blueprint.last_build_ended_at&.strftime("%-d %B %Y, %H:%M:%S")}"
      puts ""
      puts "-" * 29 + " CONTENT " + "-" * 29
      puts ""
      puts blueprint.dsl_content
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    option "content-file", type: :string, desc: "The filename of a file to be used as the Blueprintfile content", aliases: ["-c"], banner: "CONTENT_FILE"
    option "template-id", type: :string, desc: "The ID of the template to update", aliases: ["-t"], banner: "TEMPLATE_ID"
    option :name, type: :string, desc: "A nice name to be used for the blueprint", aliases: ["-n"], banner: "NICE_NAME"
    desc "update ID", "update the blueprint with ID"
    def update(id)
      CivoCLI::Config.set_api_auth
      params = {id: id}
      params[:dsl_content] = File.read(options["content-file"]) unless options["content-file"].nil?
      params[:template_id] = options["template-id"] unless options["template-id"].nil?
      params[:name] = options["name"] unless options["name"].nil?
      Civo::Blueprint.save(params)
      blueprint = Civo::Blueprint.all.detect {|b| b.id == id }
      puts "Updated blueprint #{blueprint.name.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    option "content-file", type: :string, desc: "The filename of a file to be used as the Blueprintfile content", aliases: ["-c"], banner: "CONTENT_FILE"
    option "template-id", type: :string, desc: "The ID of the template to update", aliases: ["-t"], banner: "TEMPLATE_ID"
    option :name, type: :string, desc: "A nice name to be used for the blueprint", aliases: ["-n"], banner: "NICE_NAME"
    desc "create", "create a new blueprint"
    def create
      CivoCLI::Config.set_api_auth
      params = {}
      params[:dsl_content] = File.read(options["content-file"]) unless options["content-file"].nil?
      params[:template_id] = options["template-id"] unless options["template-id"].nil?
      params[:name] = options["name"] unless options["name"].nil?
      blueprint = Civo::Blueprint.create(params)
      puts "Created blueprint #{blueprint.name.colorize(:green)} with ID #{blueprint.id.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "new" => "create"

    desc "remove ID", "remove the blueprint with ID"
    def remove(id)
      CivoCLI::Config.set_api_auth
      Civo::Blueprint.remove(id)
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "delete" => "remove", "rm" => "remove"

    default_task :list
  end
end
