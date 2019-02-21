require "spec_helper"

RSpec.describe CivoCLI::Region do
  it 'should return a list of regions' do
    stub_request(:get, "https://api.civo.com/v2/regions").
      to_return(status: 200, body: %Q/{"items": [{"code": "lon1"},{"code": "kor1"}]}/, headers: {"Content-type" => "application/json"})

    expect(capture(:stdout){
      CivoCLI::Region.new.list
    }.strip_table).to eq "Code\nlon1\nkor1"
  end

end
