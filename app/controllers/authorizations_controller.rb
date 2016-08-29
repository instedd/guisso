class AuthorizationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @trusted_roots = current_user.trusted_roots.to_a
    @authorizations = current_user.authorizations.to_a
  end

  def destroy
    authorization = current_user.authorizations.find params[:id]
    authorization.destroy
    redirect_to authorizations_path, notice: "Access from '#{authorization.client.name} to '#{authorization.resource.name}' has been revoked"
  end
end
