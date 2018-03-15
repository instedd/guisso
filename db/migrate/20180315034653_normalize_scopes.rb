class NormalizeScopes < ActiveRecord::Migration
  def up
    normalize_records("authorizations")
    normalize_records("authorization_codes")
    normalize_records("access_tokens")
  end

  def normalize_records(table_name)
    record = ActiveRecord::Base.connection.execute("SELECT id, scope FROM #{table_name}")
    record.each do |id, scope|
      normalized_scope = normalize(scope)
      if scope != normalized_scope
        ActiveRecord::Base.connection.execute <<-SQL
          UPDATE #{table_name}
          SET scope = '#{normalized_scope}'
          WHERE id = #{id}
        SQL
      end
    end
  end

  def normalize(scope)
    scope
      .split
      .reject { |s|
        s.starts_with?("app=") ||
        s.starts_with?("user=") ||
        s.starts_with?("token_type=") ||
        s.starts_with?("never_expires=")
      }
      .sort
      .join(" ")
      .presence || "all"
  end
end
