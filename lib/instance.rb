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

    if CivoCLI::Config.get_meta("admin")
      desc "", ""
      def high_cpu
        # {ENV["CIVO_API_VERSION"] || "1"}/instances/high_cpu"
      end
    end

    desc "", ""
    def find
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id", requires: [:id]
    end

    desc "", ""
    def create
      # {ENV["CIVO_API_VERSION"] || "1"}/instances", requires: [:hostname, :size, :region],
      # defaults: {public_ip: true, initial_user: "civo"}
    end

    desc "", ""
    def tags

    end

    desc "", ""
    def update

    end

    desc "", ""
    def remove
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id", requires: [:id], send_delete_body: true
    end

    desc "", ""
    def reboot
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/reboots", requires: [:id]
    end

    desc "", ""
    def hard_reboot
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/hard_reboots", requires: [:id]
    end

    desc "", ""
    def soft_reboot
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/soft_reboots", requires: [:id]
    end

    desc "", ""
    def console
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/console", requires: [:id]
    end

    desc "", ""
    def rebuild
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/rebuild", requires: [:id]
    end

    desc "", ""
    def stop
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/stop", requires: [:id]
    end

    desc "", ""
    def start
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/start", requires: [:id]
    end

    desc "", ""
    def upgrade
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/resize", requires: [:size, :id]
    end

    desc "", ""
    def restore
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/restore", requires: [:snapshot, :id]
    end

    desc "", ""
    def move_ip
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/ip/:ip", requires: [:ip, :id]
    end

    desc "", ""
    def rescue
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/rescue", requires: [:id]
    end

    desc "", ""
    def unrescue
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/unrescue", requires: [:id]
    end

    desc "", ""
    def firewall
      # {ENV["CIVO_API_VERSION"] || "1"}/instances/:id/firewall", requires: [:firewall_id, :id]
    end

    default_task :list
  end
end
