class BugsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [ :index, :new, :create ]
  before_action :set_bug, only: [ :show, :edit, :update, :destroy ]

# ------------------------------
# Project-Specific Bug List
# ------------------------------
def index
  base_bugs = @project.bugs

  # Clean search params
  clean_params = params[:q]&.dup || {}
  clean_params.delete_if { |k, v| v.blank? } # Remove empty values like "All"

  # Convert bug_type_eq to enum integer for Ransack
  if clean_params[:bug_type_eq].present?
    bug_type_key = clean_params[:bug_type_eq]
    clean_params[:bug_type_eq] = Bug.bug_types[bug_type_key] # converts "bug" => 1
  end

  @q = base_bugs.ransack(clean_params)
  @bugs = @q.result.includes(:creator, :assigned_user)
                .order(created_at: :desc)
                .paginate(page: params[:page], per_page: 10)
end

  # ------------------------------
  # New / Edit Bug
  # ------------------------------
  def new
    @bug = @project.bugs.new(bug_type: "bug", status: "new")
  end

  def edit
    redirect_to project_bugs_path(@project), alert: "Access denied." unless current_user.qa? && @bug.creator == current_user
  end

  # ------------------------------
  # Create Bug
  # ------------------------------
  def create
    @bug = @project.bugs.new(bug_params.merge(creator: current_user))
    @bug.status ||= "new"
    @bug.bug_type ||= "bug"

    if @bug.save
      notify_assigned_developer(@bug)
      redirect_to project_bugs_path(@project), notice: "Bug reported successfully."
    else
      flash.now[:alert] = @bug.errors.full_messages.join(", ")
      render :new
    end
  end

  # ------------------------------
  # Update Bug
  # ------------------------------
  def update
    notice = "Access denied."

    if current_user.developer? && @bug.assigned_user == current_user
      # Developer can only update status within allowed statuses
      new_status = params[:bug][:status]
      if @bug.available_statuses.include?(new_status)
        @bug.update(status: new_status)
        notice = "Status updated successfully."
      else
        notice = "Invalid status for this bug type."
      end

    elsif current_user.qa? && @bug.creator == current_user
      previous_assigned_user_id = @bug.assigned_user_id
      if @bug.update(bug_params)
        notice = "Bug updated successfully."
        notify_assigned_developer(@bug, previous_assigned_user_id: previous_assigned_user_id)
      else
        notice = @bug.errors.full_messages.join(", ")
      end
    end

    redirect_to project_bug_path(@project, @bug), notice: notice
  end

# GET /bugs/all_bugs
def all_bugs
  base_bugs = current_user.developer? ? Bug.where(assigned_user: current_user) : Bug.all

  clean_params = params[:q]&.dup || {}
  clean_params.delete_if { |k, v| v.blank? }

  # Convert bug_type_eq to enum integer if present
  if clean_params[:bug_type_eq].present?
    bug_type_key = clean_params[:bug_type_eq]
    clean_params[:bug_type_eq] = Bug.bug_types[bug_type_key]
  end

  @q = base_bugs.ransack(clean_params)
  @bugs = @q.result.order(created_at: :desc).paginate(page: params[:page], per_page: 10)
    # Ensure @bugs is never nil (prevents `undefined method 'any?'` error)
    @bugs ||= []
  end

  # ------------------------------
  # Destroy Bug
  # ------------------------------
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

  def notify_assigned_developer(bug, previous_assigned_user_id: nil)
    return unless bug.assigned_user.present?

    # Only send if assignment is new or changed
    return if previous_assigned_user_id && previous_assigned_user_id == bug.assigned_user_id

    # Send email
    BugAssignmentMailer.assigned_email(
      OpenStruct.new(params: { bug: bug, actor: current_user })
    ).deliver_later
  end
end
