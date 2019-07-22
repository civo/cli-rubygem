module CivoCLI
  class Volume < Thor
    desc "list", "list all volumes"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      Civo::Volume.all.items.each do |volume|
        mounted = (volume.mountpoint.nil? || volume.mountpoint == "" ? "No" : "Yes")
        rows << [volume.id, volume.name, mounted, volume.size_gb]
      end
      puts Terminal::Table.new headings: ['ID', 'Name', 'Mounted', 'Size (GB)'], rows: rows
    end
    map "ls" => "list", "all" => "list"

    desc "create NAME SIZE", "create a volume of SIZE (GB) called NAME"
    def create(name, size)
      CivoCLI::Config.set_api_auth
      size = size.to_i.to_s
      volume = Civo::Volume.create(name: name, size_gb: size)
      puts "Created a new #{size.colorize(:green)}GB volume called #{name.colorize(:green)} with ID #{volume.id.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "new" => "create"

    desc "resize ID NEW_SIZE", "resizes the volume with ID to NEW_SIZE GB"
    def resize(id, new_size)
      CivoCLI::Config.set_api_auth
      new_size = new_size.to_i.to_s
      Civo::Volume.resize(id: id, size_gb: new_size)
      volume = Civo::Volume.find(id)
      puts "Resized volume #{volume.name.colorize(:green)} with ID #{volume.id.colorize(:green)} to be #{new_size.colorize(:green)}GB"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    desc "remove ID", "remove the volume with ID"
    def remove(id)
      CivoCLI::Config.set_api_auth
      volume = Civo::Volume.find(id)
      Civo::Volume.remove(id: id)
      puts "Removed volume #{volume.name.colorize(:green)} with ID #{volume.id.colorize(:green)} (was #{volume.size_gb}GB)"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "delete" => "remove", "rm" => "remove"

    desc "attach VOLUME_ID INSTANCE_ID", "connect the volume with VOLUME_ID to the instance with INSTANCE_ID"
    def attach(volume_id, instance_id)
      CivoCLI::Config.set_api_auth
      Civo::Volume.attach(id: volume_id, instance_id: instance_id)
      volume = Civo::Volume.find(volume_id)
      instance = Civo::Instance.find(instance_id)
      puts "Attached volume #{volume.name.colorize(:green)} with ID #{volume.id.colorize(:green)} to #{instance.hostname.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "connect" => "attach", "link" => "attach"

    desc "detach ID", "disconnect the volume with ID from any instance it's connected to"
    def detach(id)
      CivoCLI::Config.set_api_auth
      Civo::Volume.detach(id: id)
      volume = Civo::Volume.find(id)
      puts "Detached volume #{volume.name.colorize(:green)} with ID #{volume.id.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "disconnect" => "detach", "unlink" => "detach"

    desc "rename ID NEW_NAME", "rename the volume with ID to have the NEW_NAME"
    def rename(id, new_name)
      CivoCLI::Config.set_api_auth
      Civo::Volume.update(id: id, name: new_name)
      volume = Civo::Volume.find(id)
      puts "Renamed volume with ID #{volume.id.colorize(:green)} to be called #{volume.name.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end

    default_task :help
  end
end
