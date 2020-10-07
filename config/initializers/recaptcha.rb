recaptcha_enabled = Guisso::Settings.recaptcha?
recaptcha_site_key = Guisso::Settings.recaptcha_site_key
recaptcha_secret_key = Guisso::Settings.recaptcha_secret_key

if recaptcha_enabled
  Recaptcha.configure do |config|
    config.site_key = recaptcha_site_key
    config.secret_key = recaptcha_secret_key
  end
end
