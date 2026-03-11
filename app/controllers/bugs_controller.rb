class BugsController < ApplicationController
  before_action :set_project, only: [ :index, :new, :create ]
  before_action :set_bug, only: [ :show, :edit, :update, :destroy ]

  # ------------------------------
  # Project-Specific Bug Inventory
  # ------------------------------
  def index
    base_bugs = Bug.where(project: @project)
    @q = base_bugs.ransack(params[:q])
    @bugs = @q.result.includes(:creator, :assigned_user).order(created_at: :desc)
  end

    def all_bugs
    # Developers see only bugs assigned to them, others see all
    base_bugs = current_user.developer? ? Bug.where(assigned_user: current_user) : Bug.all
    base_bugs = base_bugs.includes(:creator, :assigned_user, :project)

    @q = base_bugs.ransack(params[:q])
    @bugs = @q.result.order(created_at: :desc)
  end

  # ------------------------------
  # Bug Detail / Action Screen
  # ------------------------------
  def show; end

  def new
    @bug = @project.bugs.new
    @bug.bug_type ||= "feature"       # default bug type
    @bug.status ||= "new_feature"     # default status for feature
  end

def create
  @bug = @project.bugs.new(bug_params.merge(creator: current_user))

  # Set default status if blank
  if @bug.status.blank?
    @bug.status = @bug.bug_type == "feature" ? "new_feature" : "new_bug"
  end

  if @bug.save
    redirect_to project_bugs_path(@project), notice: "Bug reported successfully."
  else
    # This logs validation errors in development.log
    Rails.logger.debug "Bug could not be saved: #{@bug.errors.full_messages.join(', ')}"

    # Optional: show errors in form
    flash.now[:alert] = @bug.errors.full_messages.join(", ")
    render :new
  end
end

  def edit
    redirect_to project_bugs_path(@project), alert: "Access denied." unless current_user.qa? && @bug.creator == current_user
  end

  def update
    notice = "Access denied."

    if current_user.developer?
      if @bug.available_statuses.values.include?(params[:bug][:status])
        @bug.update(status: params[:bug][:status])
        notice = "Status updated successfully."
      else
        notice = "Invalid status for this bug type."
      end
    elsif current_user.qa? && @bug.creator == current_user
      if @bug.update(bug_params)
        notice = "Bug updated successfully."
      else
        notice = @bug.errors.full_messages.join(", ")
      end
    end

    redirect_to project_bug_path(@project, @bug), notice: notice
  end

  def destroy
    if current_user.qa? && @bug.creator == current_user
      @bug.destroy
      redirect_to project_bugs_path(@project), notice: "Bug deleted."
    else
      redirect_to project_bugs_path(@project), alert: "Access denied."
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_bug
    @bug = Bug.find(params[:id])
    @project ||= @bug.project
  end

  def bug_params
    params.require(:bug).permit(:title, :description, :bug_type, :status, :screenshot, :assigned_user_id)
  end
end
