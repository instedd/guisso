class UnifyAuthorizations < ActiveRecord::Migration
  def up
    authorizations = ActiveRecord::Base.connection
      .exec_query("SELECT id, user_id, client_id, resource_id, scope FROM authorizations")
      .group_by { |auth| {"user_id" => auth["user_id"], "client_id" => auth["client_id"], "resource_id" => auth["resource_id"] } }

    authorizations.each do |key, auths|
      unified_scope = unify_scopes auths.map {|auth| auth["scope"]}

      ActiveRecord::Base.connection.execute <<-SQL
        UPDATE authorizations
        SET scope = '#{unified_scope}'
        WHERE id = #{auths.first["id"]}
      SQL

      # puts unified_scope.inspect

      auths[1..-1].each do |auth|
        ActiveRecord::Base.connection.execute <<-SQL
          DELETE FROM authorizations
          WHERE id = #{auth["id"]}
        SQL
      end
    end
  end

  def unify_scopes(scopes)
    new_scopes = scopes
      .flat_map { |scope|
        scope
          .split(/\s+/)
          .reject { |scope| scope.starts_with?("app=") || scope.starts_with?("user=") }
          .presence || ["all"]
      }
      .uniq

    if new_scopes.include?("all")
      "all"
    else
      new_scopes.join(" ")
    end
  end
end
