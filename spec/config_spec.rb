require "spec_helper"

RSpec.describe CivoCLI::Config do

  before do
    reset_dummy_cli_config
  end

  it 'loads an existing JSON file' do
    expect(CivoCLI::Config.current).to eq(JSON.parse(File.read("dummy_file_contents")))
  end

  it 'allows retrieving all API keys' do
    expect(CivoCLI::Config.get_apikeys).to eq({"admin" => "1234567890", "client" => "abcdeabcde"})
  end

  it "allows retrieving a specified API key" do
    expect(CivoCLI::Config.get_apikey("admin")).to eq("1234567890")
  end

  it "allows retrieving the current API key" do
    expect(CivoCLI::Config.get_current_apikey).to eq("abcdeabcde")
  end

  it "allows setting an API key value" do
    temp = JSON.parse(File.read("dummy_file_contents"))
    temp["apikeys"]["other"] = "12345abcde"
    expect(File).to receive(:write).with(CivoCLI::Config.filename, temp.to_json)
    CivoCLI::Config.set_apikey("other", "12345abcde")
  end

  it "allows removing of an API key (replacing the default if it was set to this one" do
    temp = JSON.parse(File.read("dummy_file_contents"))
    temp["apikeys"].delete("client")
    temp["meta"]["current_apikey"] = "admin"
    expect(File).to receive(:write).with(CivoCLI::Config.filename, temp.to_json)
    CivoCLI::Config.delete_apikey("client")
  end

  it "allows getting of a general setting" do
    expect(CivoCLI::Config.get_meta(:default_region)).to eq("lon1")
  end

  it "allows setting of a general setting" do
    temp = JSON.parse(File.read("dummy_file_contents"))
    temp["meta"]["default_region"] = "kor2"
    expect(File).to receive(:write).with(CivoCLI::Config.filename, temp.to_json)
    CivoCLI::Config.set_meta("default_region", "kor2")
  end

end
