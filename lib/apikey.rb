module CivoCLI
  class APIKey < Thor
    desc "list", "List all stored API keys"
    def list
      keys = CivoCLI::Config.get_apikeys
      default = CivoCLI::Config.get_meta(:current_apikey)

      rows = []
      keys.each do |label, key|
        if label == default
          rows << [label, key, "<====="]
        else
          rows << [label, key, ""]
        end
      end
      puts Terminal::Table.new headings: ['Name', 'Key', 'Default?'], rows: rows
    end
    map "ls" => "list", "all" => "list"

    desc "add NAME KEY", "Add the API Key 'KEY' using a label of 'NAME'"
    def add(name, key)
      CivoCLI::Config.set_apikey(name, key)
      puts "Saved the API Key #{key.colorize(:green)} as #{name.colorize(:green)}"
      current(name)
    end

    desc "remove NAME", "Remove the API Key with a label of 'NAME'"
    def remove(name)
      keys = CivoCLI::Config.get_apikeys
        if keys.keys.include?(name)
          CivoCLI::Config.delete_apikey(name)
          puts "Removed the API Key #{name.colorize(:green)}"
        else
          puts "The API Key #{name.colorize(:red)} couldn't be found."
          exit 1
        end
    end
    map "delete" => "remove", "rm" => "remove"

    desc "current [NAME]", "Either return the name of the current API key or set the current key to be the one with a label of 'NAME'"
    def current(name = nil)
      currentkey = CivoCLI::Config.get_current_apikey_name
      if name.nil? && currentkey
          puts "The current API Key is #{currentkey.colorize(:green)}"
      elsif name.nil? && !currentkey
          puts "No current API Key set".colorize(:red)
      else
        keys = CivoCLI::Config.get_apikeys
        if keys.keys.include?(name)
          CivoCLI::Config.set_meta(:current_apikey, name)
          puts "The current API Key is now #{CivoCLI::Config.get_current_apikey_name.colorize(:green)}"
        else
          puts "The API Key #{name.colorize(:red)} couldn't be found, so it could not be set as default"
          exit 1
        end
      end
    end
    map "use" => "current"

    default_task :help
  end
end
