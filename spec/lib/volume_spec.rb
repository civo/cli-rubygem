require "spec_helper"

RSpec.describe CivoCLI::Volume do
  it "lists all volumes in the user's account" do
    expect(Civo::Volume).to receive(:all).
      and_return(double("result", items: [double("volume", id: "1", name: "myvol", mountpoint:"/dev/vdb", size_gb: 100)]))
    expect(capture(:stdout){
      CivoCLI::Volume.new.list
    }.strip_table).to eq "ID,Name,Mounted,Size (GB)\n1,myvol,Yes,100"
  end

  it "allows creating of a volume" do
    expect(Civo::Volume).to receive(:create).with(name: "foo", size_gb: "99").
      and_return(double("result", result: "success", id: "123"))
    expect(capture(:stdout){
      CivoCLI::Volume.new.create("foo", "99")
    }.strip_table).to eq "Created a new \e[0;32;49m99\e[0mGB volume called \e[0;32;49mfoo\e[0m with ID \e[0;32;49m123\e[0m"
  end

  it "allows resizing of a volume" do
    expect(Civo::Volume).to receive(:resize).with(id: "123", size_gb: "99").
      and_return(double("result", result: "success", id: "123"))
    expect(Civo::Volume).to receive(:find).with("123").
      and_return(double("result", name: "Foo", id: "123"))
    expect(capture(:stdout){
      CivoCLI::Volume.new.resize("123", "99")
    }.strip_table).to eq "Resized volume \e[0;32;49mFoo\e[0m with ID \e[0;32;49m123\e[0m to be \e[0;32;49m99\e[0mGB"
  end

  it "allows removing of a volume" do
    expect(Civo::Volume).to receive(:remove).with(id: "123").
      and_return(double("result", result: "success", id: "123"))
    expect(Civo::Volume).to receive(:find).with("123").
      and_return(double("result", name: "Foo", id: "123", size_gb: 99))
    expect(capture(:stdout){
      CivoCLI::Volume.new.remove("123")
    }.strip_table).to eq "Removed volume \e[0;32;49mFoo\e[0m with ID \e[0;32;49m123\e[0m (was 99GB)"
  end

  it "allows attaching of a volume to an instance" do
    expect(Civo::Volume).to receive(:attach).with(id: "123", instance_id: "456").
      and_return(double("result", result: "success", id: "123"))
    expect(Civo::Instance).to receive(:find).with("456").
      and_return(double("result", id: "456", hostname: "Bar"))
    expect(Civo::Volume).to receive(:find).with("123").
      and_return(double("result", name: "Foo", id: "123", size_gb: 99))

    expect(capture(:stdout){
      CivoCLI::Volume.new.attach("123", "456")
    }.strip_table).to eq "Attached volume \e[0;32;49mFoo\e[0m with ID \e[0;32;49m123\e[0m to \e[0;32;49mBar\e[0m"
  end

  it "allows detaching of a volume from the instance it's attached to" do
    expect(Civo::Volume).to receive(:detach).with(id: "123").
      and_return(double("result", result: "success", id: "123"))
    expect(Civo::Volume).to receive(:find).with("123").
      and_return(double("result", name: "Foo", id: "123", size_gb: 99))

    expect(capture(:stdout){
      CivoCLI::Volume.new.detach("123")
    }.strip_table).to eq "Detached volume \e[0;32;49mFoo\e[0m with ID \e[0;32;49m123\e[0m"
  end

  it "allows renaming of a volume" do
    expect(Civo::Volume).to receive(:update).with(id: "123", name: "Foo").
      and_return(double("result", result: "success", id: "123"))
    expect(Civo::Volume).to receive(:find).with("123").
      and_return(double("result", name: "Foo", id: "123", size_gb: 99))

    expect(capture(:stdout){
      CivoCLI::Volume.new.rename("123", "Foo")
    }.strip_table).to eq "Renamed volume with ID \e[0;32;49m123\e[0m to be called \e[0;32;49mFoo\e[0m"
  end

end
