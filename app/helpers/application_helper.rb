module ApplicationHelper
  def alto_guisso_yml(application)
    "enabled: true
url: #{request.protocol}#{request.host_with_port}
client_id: #{application.identifier}
client_secret: #{application.secret}
"
  end
end
