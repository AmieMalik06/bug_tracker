class BugsController < ApplicationController
  before_action :set_project
  before_action :set_bug, only: [ :show, :edit, :update, :destroy ]

  def index
    @q = @project.bugs.ransack(params[:q])
    @bugs = @q.result
  end

  def new
    @bug = @project.bugs.new
  end

  def create
    @bug = @project.bugs.new(bug_params.merge(creator: current_user))
    if @bug.save
      notify_assignment(@bug)
      redirect_to project_bugs_path(@project), notice: "Bug reported successfully."
    else
      render :new
    end
  end

  def update
    if current_user.developer?
      @bug.update(status: params[:bug][:status])
    elsif current_user.qa? && @bug.creator == current_user
      @bug.update(bug_params)
    end
    redirect_to project_bug_path(@project, @bug)
  end

  def destroy
    if current_user.qa? && @bug.creator == current_user
      @bug.destroy
      redirect_to project_bugs_path(@project), notice: "Bug deleted."
    else
      redirect_to project_bug_path(@project, @bug), alert: "Access denied."
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_bug
    @bug = @project.bugs.find(params[:id])
  end

  def bug_params
    params.require(:bug).permit(:title, :description, :bug_type, :status, :screenshot)
  end

  def notify_assignment(bug)
    # Use ActivityNotification for in-app + email alerts
    # ActivityNotification.notify(bug.assigned_user, :assigned_bug, parameters: { bug_id: bug.id })
  end
end
