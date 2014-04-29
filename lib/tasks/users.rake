namespace :users do
  desc "Import users from a CSV file"
  task :import, [:file] => :environment do |t, args|
    file = args[:file]
    abort "Missing csv file. Please invoke the task like this: rake users:import[path_to_csv_file]" unless file.present?

    abort "File '#{file}' does not exist" unless File.exists?(file)
    abort "'#{file}' is not a file" unless File.file?(file)

    require "csv"

    User.transaction do
      first = true
      indices = []
      CSV.foreach(file) do |row|
        row = row.map{|element| (element || "").strip}
        if first
          row.each do |col|
            case col
            when /email/i
              indices.push :email
            when /password/i
              indices.push :encrypted_password
            when /name/i
              indices.push :name
            when /pepper/i
              indices.push :pepper
            else
              abort "Unknown header: #{col} (headers must be email, name or password)"
            end
          end
          first = false
        else
          attributes = {}
          indices.each_with_index do |name, i|
            attributes[name] = row[i]
          end

          user = User.find_by_email(attributes[:email])
          if user
            puts "Add extra password for #{attributes[:email]}"
            extra = user.extra_passwords.new
            extra.password = "it_doesnt_matter"
            extra.encrypted_password = attributes[:encrypted_password]
            extra.pepper = attributes[:pepper]
            def extra.encrypted_password=(password); end
            extra.save!
          else
            if attributes[:name].present?
              puts "Create #{attributes[:name]} <#{attributes[:email]}>"
            else
              puts "Create #{attributes[:email]}"
            end

            pepper = attributes[:pepper]

            attributes.delete(:pepper)

            user = User.new attributes
            user.password = "it_doesnt_matter"
            user.encrypted_password = attributes[:encrypted_password]
            def user.encrypted_password=(password); end
            user.confirmed_at = Time.now - 1.day
            user.save!

            if pepper
              extra = user.extra_passwords.new
              extra.password = "it_doesnt_matter"
              extra.encrypted_password = attributes[:encrypted_password]
              extra.pepper = pepper
              def extra.encrypted_password=(password); end
              extra.save!
            end
          end
        end
      end
    end
  end
end
