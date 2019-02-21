require "spec_helper"

RSpec.describe CivoCLI::APIKey do
  it 'should return a list of API keys' do
    expect(capture(:stdout){
      CivoCLI::APIKey.new.list
    }.strip_table).to eq "Name,Key,Default?\nadmin,1234567890,\nclient,abcdeabcde,<====="
  end

  it 'should add a new key' do
    expect(capture(:stdout){
      CivoCLI::APIKey.new.add("foo", "bar")
      CivoCLI::APIKey.new.list
    }.strip_table).to eq "Saved the API Key \e[0;32;49mbar\e[0m as \e[0;32;49mfoo\e[0m\n" + "Name,Key,Default?\nadmin,1234567890,\nclient,abcdeabcde,<=====\nfoo,bar,"
  end

  it 'should remove a key' do
    expect(capture(:stdout){
      CivoCLI::APIKey.new.remove("client")
      CivoCLI::APIKey.new.list
    }.strip_table).to eq "Removed the API Key \e[0;32;49mclient\e[0m\n" + "Name,Key,Default?\nadmin,1234567890,<====="
  end

  it 'should get the current key' do
    expect(capture(:stdout){
      CivoCLI::APIKey.new.current
    }.strip_table).to eq "The current API Key is \e[0;32;49mclient\e[0m"
  end

  it 'should set the current key' do
    expect(capture(:stdout){
      CivoCLI::APIKey.new.current("admin")
    }.strip_table).to eq "The current API Key is now \e[0;32;49madmin\e[0m"
  end


end
