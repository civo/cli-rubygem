module CivoCLI
  class Config
    def self.get_apikeys
      current["apikeys"]
    end

    def self.get_apikey(key)
      current["apikeys"][key]
    end

    def self.get_current_apikey
      current["apikeys"][get_current_apikey_name]
    end

    def self.get_current_apikey_name
      get_meta(:current_apikey)
    end

    def self.set_current_apikey_name(name)
      set_meta(:current_apikey, name)
    end

    def self.set_apikey(key, value)
      current["apikeys"][key] = value
      save
    end

    def self.delete_apikey(key)
      current["apikeys"].delete(key)
      if get_current_apikey_name == key
        if get_apikeys.any?
          set_current_apikey_name(get_apikeys.keys.first)
        else
          set_current_apikey_name(nil)
        end
      end
    end

    def self.get_meta(key)
      current["meta"].transform_keys{ |key| key.to_sym rescue key }[key]
    rescue
      nil
    end

    def self.set_meta(key, value)
      current["meta"][key.to_s] = value
      save
    end

    def self.current
      @config ||= JSON.parse(File.read(filename))
    rescue
      @config = {}
    end

    def self.reset
      @config = nil
    end

    def self.save
      File.write(filename, @config.to_json)
    end

    def self.filename
      "#{ENV['HOME']}/.civo.json"
    end

    def self.set_api_auth
      ENV["CIVO_API_VERSION"] = "2"
      ENV["CIVO_TOKEN"] = CivoCLI::Config.get_current_apikey
      if ENV["CIVO_TOKEN"].nil? || ENV["CIVO_TOKEN"] == ""
        puts "#{"Unable to connect:".colorize(:red)} No valid API key is set"
        exit 1
      end
      ENV["CIVO_URL"] = CivoCLI::Config.get_meta(:url) || "https://api.civo.com"
    end
  end
end
