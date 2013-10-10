class ApplicationsController < ApplicationController
  load_and_authorize_resource

  def create
    respond_to do |format|
      if @application.save
        format.html { redirect_to @application, notice: 'Application was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @application = Application.find(params[:id])

    authorize! :update, @application

    respond_to do |format|
      if @application.update_attributes(application_params)
        format.html { redirect_to @application, notice: 'Application was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @application.destroy

    respond_to do |format|
      format.html { redirect_to applications_url }
    end
  end

  private

  def application_params
    params.require(:application).permit(:name, :hostname, :is_client, :is_provider, :trusted)
  end
end
