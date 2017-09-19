module Guisso
  class Settings
    Config = YAML.load_file("#{Rails.root}/config/settings.yml")

    def self.devise_confirmable
      if env_value = ENV["DEVISE_CONFIRMABLE"]
        env_value == "true"
      else
        Config["devise_confirmable"]
      end
    end

    def self.devise_secret_key
      ENV["DEVISE_SECRET_KEY"] || Config["devise_secret_key"]
    end

    def self.devise_email
      ENV["DEVISE_EMAIL"] || Config["devise_email"]
    end

    def self.secret_token
      ENV["SECRET_TOKEN"] || Config["secret_token"]
    end

    def self.whitelisted_hosts
      if env_value = ENV["WHITELISTED_HOSTS"]
        env_value.split(",").map(&:strip)
      else
        Config["whitelisted_hosts"]
      end
    end

    def self.google_client_id
      ENV["GOOGLE_CLIENT_ID"] || Config["google"]["client_id"]
    end

    def self.google_client_secret
      ENV["GOOGLE_CLIENT_SECRET"] || Config["google"]["client_secret"]
    end

    def self.cookie_name
      ENV["COOKIE_NAME"] || Config["cookie"]["name"]
    end

    def self.cookie_domain
      ENV["COOKIE_DOMAIN"] || Config["cookie"]["domain"]
    end
  end
end
