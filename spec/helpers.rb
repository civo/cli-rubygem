module Helpers
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def reset_dummy_cli_config
    config_file_contents = '{
        "apikeys": {
          "admin": "1234567890",
          "client": "abcdeabcde"
        },
        "meta": {
          "admin": false,
          "current_apikey": "client",
          "default_region": "lon1",
          "latest_release_check": "2019-02-20T12:27:16Z",
          "url": "https://api.civo.com"
        }
      }'

    allow(File).to receive(:read).and_return(config_file_contents)
    allow(CivoCLI::Config).to receive(:filename).and_return("/dev/null")
    CivoCLI::Config.reset
  end
end

class String
  def strip_table
    self.lines.map do |line|
      line.
        gsub(/\+[\-\+]+\+\n/msi, "").
        gsub(/ +\| +/msi, ",").
        gsub(/^\| /msi, "").
        gsub(/\|$/m, "").
        strip
    end.reject {|l| l == ""}.join("\n")
  rescue
    self
  end
end
