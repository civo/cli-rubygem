require "spec_helper"

RSpec.describe CivoCLI::Quota do
  it 'should get the current quota' do
    stub_request(:get, "https://api.civo.com/v2/quota").
      to_return(status: 200, body: %Q/{
                "instance_count_limit": 128, "instance_count_usage": 26, "cpu_core_limit": 128, "cpu_core_usage": 63, "ram_mb_limit": 131072, "ram_mb_usage": 64512, "disk_gb_limit": 3200, "disk_gb_usage": 2086, "disk_volume_count_limit": 128, "disk_volume_count_usage": 29, "disk_snapshot_count_limit": 30, "disk_snapshot_count_usage": 1, "public_ip_address_limit": 128, "public_ip_address_usage": 26, "subnet_count_limit": 10, "subnet_count_usage": 1, "network_count_limit": 10, "network_count_usage": 1, "security_group_limit": 32, "security_group_usage": 4, "security_group_rule_limit": 160, "security_group_rule_usage": 45, "port_count_limit": 256, "port_count_usage": 27
                }
                /, headers: {"Content-type" => "application/json"})
    expect(capture(:stdout){
      CivoCLI::Quota.new.show
    }.strip_table).to eq "Item,Usage,Limit\nInstances,26,128\nCPU cores,63,128\nRAM MB,64512,131072\nDisk GB,2086,3200\nVolumes,29,128\nSnapshots,1,30\nPublic IPs,26,128\nSubnets,1,10\nPrivate networks,1,10\nFirewalls,4,32\nFirewall rules,45,160\nAny items in \e[0;31;49mred\e[0m are at least 80% of your limit"
  end

  it 'highlights in red any items at over over 80% of the limit' do
    stub_request(:get, "https://api.civo.com/v2/quota").
      to_return(status: 200, body: %Q/{
                "instance_count_limit": 128, "instance_count_usage": 26, "cpu_core_limit": 100, "cpu_core_usage": 80, "ram_mb_limit": 131072, "ram_mb_usage": 64512, "disk_gb_limit": 3200, "disk_gb_usage": 2086, "disk_volume_count_limit": 128, "disk_volume_count_usage": 29, "disk_snapshot_count_limit": 30, "disk_snapshot_count_usage": 1, "public_ip_address_limit": 128, "public_ip_address_usage": 26, "subnet_count_limit": 10, "subnet_count_usage": 1, "network_count_limit": 10, "network_count_usage": 1, "security_group_limit": 32, "security_group_usage": 4, "security_group_rule_limit": 160, "security_group_rule_usage": 45, "port_count_limit": 256, "port_count_usage": 27
                }
                /, headers: {"Content-type" => "application/json"})
    expect(capture(:stdout){
      CivoCLI::Quota.new.show
    }.strip_table).to eq "Item,Usage,Limit\nInstances,26,128\nCPU cores,\e[0;31;49m80\e[0m,100\nRAM MB,64512,131072\nDisk GB,2086,3200\nVolumes,29,128\nSnapshots,1,30\nPublic IPs,26,128\nSubnets,1,10\nPrivate networks,1,10\nFirewalls,4,32\nFirewall rules,45,160\nAny items in \e[0;31;49mred\e[0m are at least 80% of your limit"
  end


end
