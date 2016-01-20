VersionFilePath = "#{::Rails.root.to_s}/VERSION"
RevisionFilePath = "#{::Rails.root.to_s}/REVISION"

Guisso::Application.config.send "version_name=", if FileTest.exists?(VersionFilePath) then
  IO.read(VersionFilePath)
elsif FileTest.exists?(RevisionFilePath)
  IO.read(RevisionFilePath)
else
  "development"
end
