module CivoCLI
  class Size < Thor
    desc "list", "List all sizes available for selection"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      Civo::Size.all.items.select{|s| s.selectable }.each do |size|
        rows << [size.name, size.description, size.cpu_cores, size.ram_mb, size.disk_gb]
      end
      puts Terminal::Table.new headings: ['Name', 'Description', 'CPU', 'RAM (MB)', 'Disk (GB)'], rows: rows
    end

    default_task :list

  end
end
