module CivoCLI
  class Template < Thor
    desc "list", "list all templates"
    option :verbose, type: :boolean, desc: "Show verbose template detail", aliases: ["-v"] 
    def list
      CivoCLI::Config.set_api_auth
      rows = []

      if options[:verbose]
        Civo::Template.all.items.each do |template|
          rows << [template.id, template.name, template.image_id, template.volume_id, template.default_username]
        end
        puts Terminal::Table.new headings: ['ID', 'Name', 'Image ID', 'Volume ID', "Default Username"], rows: rows
      
      else
        Civo::Template.all.items.each do |template|
          rows << [template.id, template.name]
        end
        puts Terminal::Table.new headings: ['ID', 'Name'], rows: rows
      end

    
      rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "ls" => "list", "all" => "list"

    desc "show ID", "show the details for a single template"
    def show(id)
      CivoCLI::Config.set_api_auth
      template = Civo::Template.details(id)
      puts "               ID: #{template.id}"
      puts "             Code: #{template.code}"
      puts "             Name: #{template.name}"
      puts "         Image ID: #{template.image_id}"
      puts "        Volume ID: #{template.volume_id}"
      puts "Short Description: #{template.short_description}"
      puts "      Description: #{template.description}"
      puts " Default Username: #{template.default_username}"
      puts ""
      puts "-" * 29 + "CLOUD CONFIG" + "-" * 29
      puts template.cloud_config
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    option "cloud-init-file", type: :string, desc: "The filename of a file to be used as user-data/cloud-init", aliases: ["-c"], banner: "CLOUD_INIT_FILENAME"
    option :description, type: :string, desc: "A full/long multiline description", aliases: ["-d"], banner: "DESCRIPTION"
    option "image-id", type: :string, desc: "The glance ID of the base filesystem image", aliases: ["-i"], banner: "IMAGE_ID"
    option "volume-id", type: :string, desc: "The volume ID of the base filesystem volume", aliases: ["-v"], banner: "VOLUME_ID"
    option :name, type: :string, desc: "A nice name to be used for the template", aliases: ["-n"], banner: "NICE_NAME"
    option "short-description", type: :string, desc: "A one line short summary of the template", aliases: ["-s"], banner: "SUMMARY"
    desc "update ID", "update the template with ID"
    def update(id)
      CivoCLI::Config.set_api_auth
      params = {id: id}
      params[:cloud_config] = File.read(options["cloud-init-file"]) unless options["cloud-init-file"].nil?
      params[:image_id] = options["image-id"] unless options["image-id"].nil?
      params[:volume_id] = options["volume-id"] unless options["volume-id"].nil?
      params[:description] = options["description"] unless options["description"].nil?
      params[:name] = options["name"] unless options["name"].nil?
      params[:short_description] = options["short-description"] unless options["short-description"].nil?
      Civo::Template.save(params)
      template = Civo::Template.details(id)
      puts "Updated template #{template.name.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    option "cloud-init-file", type: :string, desc: "The filename of a file to be used as user-data/cloud-init", aliases: ["-c"], banner: "CLOUD_INIT_FILENAME"
    option :description, type: :string, desc: "A full/long multiline description", aliases: ["-d"], banner: "DESCRIPTION"
    option "image-id", type: :string, desc: "The glance ID of the base filesystem image", aliases: ["-i"], banner: "IMAGE_ID"
    option "volume-id", type: :string, desc: "The volume ID of the base filesystem volume", aliases: ["-v"], banner: "VOLUME_ID"
    option :name, type: :string, desc: "A nice name to be used for the template", aliases: ["-n"], banner: "NICE_NAME"
    option "short-description", type: :string, desc: "A one line short summary of the template", aliases: ["-s"], banner: "SUMMARY"
    desc "create", "create a new template"
    def create
      CivoCLI::Config.set_api_auth
      params = {}
      params[:cloud_config] = File.read(options["cloud-init-file"]) unless options["cloud-init-file"].nil?
      params[:image_id] = options["image-id"] unless options["image-id"].nil?
      params[:volume_id] = options["volume-id"] unless options["volume-id"].nil?
      params[:description] = options["description"] unless options["description"].nil?
      params[:name] = options["name"] unless options["name"].nil?
      params[:short_description] = options["short-description"] unless options["short-description"].nil?
      template = Civo::Template.create(params)
      puts "Created template #{template.name.colorize(:green)} with ID #{template.id.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "new" => "create"

    desc "remove ID", "remove the template with ID"
    def remove(id)
      CivoCLI::Config.set_api_auth
      Civo::Template.remove(id)
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "delete" => "remove", "rm" => "remove"

    default_task :help
  end
end
