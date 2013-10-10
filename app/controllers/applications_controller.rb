class ApplicationsController < ApplicationController
  load_and_authorize_resource

  skip_load_resource only: [:create, :update]

  before_filter :create_application, only: :create
  before_filter :load_application, only: :update

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

  def load_application
    @application = Application.find(params[:id])
  end

  def create_application
    @application = Application.new(application_params)
  end
end
