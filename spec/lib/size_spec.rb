require "spec_helper"

RSpec.describe CivoCLI::Size do
  it 'should return a list of regions' do
    stub_request(:get, "https://api.civo.com/v2/sizes").
      to_return(status: 200, body: %Q/{"items": [{"name": "foo", "description": "A huge foo", "cpu_cores": 3, "ram_mb": 2048, "disk_gb": 200, "selectable": true},{"name": "bar", "description": "A hidden bar", "cpu_cores": 5, "ram_mb": 4192, "disk_gb": 400, "selectable": false}]}/, headers: {"Content-type" => "application/json"})

    expect(capture(:stdout){
      CivoCLI::Size.new.list
    }.strip_table).to eq "Name,Description,CPU,RAM (MB),Disk (GB)\nfoo,A huge foo,3,2048,200"

  end
end
