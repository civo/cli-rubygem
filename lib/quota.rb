module CivoCLI
  class Quota < Thor
    desc "show", "show the current quota and usage"
    def show
      CivoCLI::Config.set_api_auth
      rows = []
      quota = Civo::Quota.current
      if quota.instance_count_usage >= (quota.instance_count_limit * 0.8)
        rows << ["Instances", quota.instance_count_usage.to_s.colorize(:red), quota.instance_count_limit]
      else
        rows << ["Instances", quota.instance_count_usage, quota.instance_count_limit]
      end
      if quota.cpu_core_usage >= (quota.cpu_core_limit * 0.8)
        rows << ["CPU cores", quota.cpu_core_usage.to_s.colorize(:red), quota.cpu_core_limit]
      else
        rows << ["CPU cores", quota.cpu_core_usage, quota.cpu_core_limit]
      end
      if quota.ram_mb_usage >= (quota.ram_mb_limit * 0.8)
        rows << ["RAM MB", quota.ram_mb_usage.to_s.colorize(:red), quota.ram_mb_limit]
      else
        rows << ["RAM MB", quota.ram_mb_usage, quota.ram_mb_limit]
      end
      if quota.disk_gb_usage >= (quota.disk_gb_limit * 0.8)
        rows << ["Disk GB", quota.disk_gb_usage.to_s.colorize(:red), quota.disk_gb_limit]
      else
        rows << ["Disk GB", quota.disk_gb_usage, quota.disk_gb_limit]
      end
      if quota.disk_volume_count_usage >= (quota.disk_volume_count_limit * 0.8)
        rows << ["Volumes", quota.disk_volume_count_usage.to_s.colorize(:red), quota.disk_volume_count_limit]
      else
        rows << ["Volumes", quota.disk_volume_count_usage, quota.disk_volume_count_limit]
      end
      if quota.disk_snapshot_count_usage >= (quota.disk_snapshot_count_limit * 0.8)
        rows << ["Snapshots", quota.disk_snapshot_count_usage.to_s.colorize(:red), quota.disk_snapshot_count_limit]
      else
        rows << ["Snapshots", quota.disk_snapshot_count_usage, quota.disk_snapshot_count_limit]
      end
      if quota.public_ip_address_usage >= (quota.public_ip_address_limit * 0.8)
        rows << ["Public IPs", quota.public_ip_address_usage.to_s.colorize(:red), quota.public_ip_address_limit]
      else
        rows << ["Public IPs", quota.public_ip_address_usage, quota.public_ip_address_limit]
      end
      if quota.subnet_count_usage >= (quota.subnet_count_limit * 0.8)
        rows << ["Subnets", quota.subnet_count_usage.to_s.colorize(:red), quota.subnet_count_limit]
      else
        rows << ["Subnets", quota.subnet_count_usage, quota.subnet_count_limit]
      end
      if quota.network_count_usage >= (quota.network_count_limit * 0.8)
        rows << ["Private networks", quota.network_count_usage.to_s.colorize(:red), quota.network_count_limit]
      else
        rows << ["Private networks", quota.network_count_usage, quota.network_count_limit]
      end
      if quota.security_group_usage >= (quota.security_group_limit * 0.8)
        rows << ["Firewalls", quota.security_group_usage.to_s.colorize(:red), quota.security_group_limit]
      else
        rows << ["Firewalls", quota.security_group_usage, quota.security_group_limit]
      end
      if quota.security_group_rule_usage >= (quota.security_group_rule_limit * 0.8)
        rows << ["Firewall rules", quota.security_group_rule_usage.to_s.colorize(:red), quota.security_group_rule_limit]
      else
        rows << ["Firewall rules", quota.security_group_rule_usage, quota.security_group_rule_limit]
      end
      puts Terminal::Table.new headings: ["Item", "Usage", "Limit"], rows: rows
      puts "Any items in #{"red".to_s.colorize(:red)} are at least 80% of your limit"
    end

    default_task :show
  end
end
