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

    default_task :list
  end
end
