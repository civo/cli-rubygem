module CivoCLI
  class Snapshot < Thor
    desc "list", "list all snapshots"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      Civo::Snapshot.all.items.each do |snapshot|
        rows << [snapshot.id, snapshot.name, snapshot.state, snapshot.size_gb, (snapshot.cron_timing || "One-off")]
      end
      puts Terminal::Table.new headings: ['ID', 'Name', 'State', "Size (GB)", "Cron"], rows: rows
    end

    option "cron", type: :string, desc: "The timing of when to take/repeat in cron format", aliases: ["-c"], banner: "CRON_TIMING"
    desc "create NAME INSTANCE_ID [-c '0 * * * *']", "create a snapshot called NAME from instance INSTANCE_ID"
    def create(name, instance_id)
      CivoCLI::Config.set_api_auth
      puts options.inspect
      params = {name: name, instance_id: instance_id}
      params[:cron_timing] = options["cron"] unless options["cron"].nil?
      snapshot = Civo::Snapshot.create(params)
      puts "Created snapshot #{name.colorize(:green)} with ID #{snapshot.id.colorize(:green)} #{"with cron timing #{options["cron"].colorize(:green)}" unless options["cron"].nil?}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "new" => "create"

    desc "remove ID", "remove the snapshot ID"
    def remove(id)
      CivoCLI::Config.set_api_auth
      snapshot = Civo::Snapshot.all.items.detect {|key| key.id == id}
      Civo::Snapshot.remove(id: id)
      puts "Removed snapshot #{snapshot.name.colorize(:green)} with ID #{snapshot.id.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "delete" => "remove", "rm" => "remove"

    default_task :list

  end
end
