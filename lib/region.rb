module CivoCLI
  class Region < Thor
    desc "list", "List all regions available for selection"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      Civo::Region.all.items.each do |region|
        rows << [region.code]
      end
      puts Terminal::Table.new headings: ['Code'], rows: rows
    end

    default_task :list
  end
end
