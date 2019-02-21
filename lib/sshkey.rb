module CivoCLI
  class SSHKey < Thor
    desc "list", "list all SSH keys"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      Civo::SshKey.all.items.each do |key|
        rows << [key.id, key.name, key.fingerprint]
      end
      puts Terminal::Table.new headings: ['ID', 'Name', 'Fingerprint'], rows: rows
    end

    desc "upload NAME FILENAME", "upload the SSH public key in FILENAME to a new key called NAME"
    def upload(name, filename)
      CivoCLI::Config.set_api_auth
      ssh_key = Civo::SshKey.create(name: name, public_key: File.read(filename))
      puts "Uploaded SSH key #{name.colorize(:green)} with ID #{ssh_key.id.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "create" => "upload", "new" => "upload"

    desc "upload NAME FILENAME", "upload the SSH public key in FILENAME to a new key called NAME"
    def remove(id)
      CivoCLI::Config.set_api_auth
      ssh_key = Civo::SshKey.all.items.detect {|key| key.id == id}
      Civo::SshKey.remove(id: id)
      puts "Removed SSH key #{ssh_key.name.colorize(:green)} with ID #{ssh_key.id.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "delete" => "remove", "rm" => "remove"

    default_task :list
  end
end
