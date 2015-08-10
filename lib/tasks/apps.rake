require 'optparse'

namespace :apps do

  desc "Creates or retrieves an application in this GUISSO server, and returns its identifier and secret in YAML"
  task :create, [:name, :host, :trusted] => :environment do |task, args|
    args.with_defaults(trusted: false)

    attrs = {}
    attrs[:name] = args[:name].strip
    attrs[:hostname] = args[:host].strip
    attrs[:trusted] = (args[:trusted] == 'trusted')

    app = Application.where(hostname: attrs[:hostname]).first || Application.create!(attrs)
    puts "client_id: #{app.identifier}\nclient_secret: #{app.secret}"
  end

end
