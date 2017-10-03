class SetDefaultScopeToAccessTokens < ActiveRecord::Migration
  def up
    access_tokens = ActiveRecord::Base.connection.execute <<-SQL
      SELECT id, resource_id, user_id
      FROM access_tokens
      WHERE scope IS NULL
    SQL

    access_tokens.each do |id, resource_id, user_id|
      app = ActiveRecord::Base.connection.select_one <<-SQL
        SELECT hostname
        FROM applications
        WHERE id = #{resource_id}
      SQL
      user = ActiveRecord::Base.connection.select_one <<-SQL
        SELECT email
        FROM users
        WHERE id = #{user_id}
      SQL
      ActiveRecord::Base.connection.execute <<-SQL
        UPDATE access_tokens
        SET scope = 'app=#{app["hostname"]} user=#{user["email"]}'
        WHERE id = #{id}
      SQL
    end
  end
end
