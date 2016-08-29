class TrustedRootsController < ApplicationController
  before_filter :authenticate_user!

  def destroy
    trusted_root = current_user.trusted_roots.find params[:id]
    trusted_root.destroy
    redirect_to authorizations_path, notice: "Access to '#{trusted_root.url}' has been revoked"
  end
end
