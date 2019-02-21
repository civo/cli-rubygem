require "spec_helper"

RSpec.describe CivoCLI::Template do
  it "allows listing of templates" do
    expect(Civo::Template).to receive(:all).and_return(double("result", items: [double("item", id: "1", name: "Ubuntu 16.04", image_id: "2", volume_id: "3", default_username: "ubuntu")]))
    expect(capture(:stdout){
      CivoCLI::Template.new.list
    }.strip_table).to eq "ID,Name,Image ID,Volume ID,Default Username\n1,Ubuntu 16.04,2,3,ubuntu"
  end

  it "allows showing the full details of templates" do
    expect(Civo::Template).to receive(:details).with("1").and_return(double("item", id: "1", code: "ubuntu-16.04", name: "Ubuntu 16.04", image_id: "2", volume_id: "3", short_description: "this is a short desc", description: "this is a long description", default_username: "ubuntu", cloud_config: "something\ngoes\nhere"))
    expect(capture(:stdout){
      CivoCLI::Template.new.show("1")
    }.strip_table).to eq "ID: 1\nCode: ubuntu-16.04\nName: Ubuntu 16.04\nImage ID: 2\nVolume ID: 3\nShort Description: this is a short desc\nDescription: this is a long description\nDefault Username: ubuntu\n-----------------------------CLOUD CONFIG-----------------------------\nsomething\ngoes\nhere"
  end

  it "allows updating a template"
    # expect(Civo::Template).to receive(:update).with(id: "1", name: "Foo").and_return(double("item", id: "1", code: "ubuntu-16.04", name: "Ubuntu 16.04", image_id: "2", volume_id: "3", short_description: "this is a short desc", description: "this is a long description", default_username: "ubuntu", cloud_config: "something\ngoes\nhere"))
    # expect(Civo::Template).to receive(:details).with("1").and_return(double("item", id: "1", code: "ubuntu-16.04", name: "Ubuntu 16.04", image_id: "2", volume_id: "3", short_description: "this is a short desc", description: "this is a long description", default_username: "ubuntu", cloud_config: "something\ngoes\nhere"))
    # expect(capture(:stdout){
    #   object = CivoCLI::Template.new
    #   object.options = {name: "Foo"}
    #   object.update("1")
    # }.strip_table).to eq "ID: 1\nCode: ubuntu-16.04\nName: Ubuntu 16.04\nImage ID: 2\nVolume ID: 3\nShort Description: this is...untu\n-----------------------------CLOUD CONFIG-----------------------------\nsomething\ngoes\nhere"


end

