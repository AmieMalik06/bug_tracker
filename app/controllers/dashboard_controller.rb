class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.manager?
      @projects = Project.all
      @pending_bugs = Bug.where.not(status: [ :completed, :resolved ])
    else
      @projects = current_user.projects || []
      @pending_bugs = Bug.joins(:project)
                         .where(projects: { id: @projects.pluck(:id) })
                         .where.not(status: [ :completed, :resolved ])
    end
  end
end
