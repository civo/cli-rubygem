require "spec_helper"

RSpec.describe CivoCLI::SSHKey do
  it "allows listing of all uploaded SSH keys" do
    expect(Civo::SshKey).to receive(:all).
      and_return(double("result", items: [double("key", id: "1", name: "my-key", fingerprint:"00:00:00:00:00:00")]))
    expect(capture(:stdout){
      CivoCLI::SSHKey.new.list
    }.strip_table).to eq "ID,Name,Fingerprint\n1,my-key,00:00:00:00:00:00"
  end

  it "allow uploading of a new SSH key" do
    filename = File.join(__FILE__, "..", "support", "example.pub")
    expect(Civo::SshKey).to receive(:create).with(name: "new-key", public_key: File.read(filename)).
      and_return(double("result", id: "1", name: "my-key", fingerprint:"00:00:00:00:00:00"))
    expect(capture(:stdout){
      CivoCLI::SSHKey.new.upload("new-key", filename)
    }.strip_table).to eq "Uploaded SSH key \e[0;32;49mnew-key\e[0m with ID \e[0;32;49m1\e[0m"
  end

  it "allows removal of SSH keys" do
    expect(Civo::SshKey).to receive(:all).
      and_return(double("result", items: [double("key", id: "1", name: "my-key", fingerprint:"00:00:00:00:00:00")]))
    expect(Civo::SshKey).to receive(:remove).with(id: "1")
    expect(capture(:stdout){
      CivoCLI::SSHKey.new.remove("1")
    }.strip_table).to eq "Removed SSH key \e[0;32;49mmy-key\e[0m with ID \e[0;32;49m1\e[0m"
  end
end
