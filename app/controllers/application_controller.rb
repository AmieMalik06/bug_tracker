class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :role ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :role ])
  end

  def after_sign_in_path_for(resource)
    if resource.manager?
      projects_path
    elsif resource.qa? || resource.developer?
      # Redirect QA/Dev to first assigned project bugs
      first_project = resource.projects.first
      first_project ? project_bugs_path(first_project) : projects_path
    else
      dashboard_path
    end
  end
end
