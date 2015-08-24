module Guisso
  class Settings
    Config = YAML.load_file("#{Rails.root}/config/settings.yml")

    def self.devise_confirmable
      Config["devise_confirmable"]
    end

    def self.devise_secret_key
      Config["devise_secret_key"]
    end

    def self.devise_email
      Config["devise_email"]
    end

    def self.secret_token
      Config["secret_token"]
    end

    def self.whitelisted_hosts
      Config["whitelisted_hosts"]
    end

    def self.google
      Config["google"]
    end
  end
end
