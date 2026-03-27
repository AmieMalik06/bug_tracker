class ProjectsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource except: [ :index, :assign_users, :update_users ]
  before_action :set_project, only: [ :show, :edit, :update, :destroy, :assign_users, :update_users ]

  # Project Listing / Dashboard
  def index
    # Managers see all projects; others see assigned projects only
    base_projects = current_user.manager? ? Project.all : current_user.projects

    # Ransack search + pagination
    @q = base_projects.ransack(params[:q])
    @projects = @q.result.includes(:users).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
  end

  def show; end

  # Manager Only CRUD
  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to projects_path, notice: "Project created successfully."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @project.update(project_params)
      redirect_to projects_path, notice: "Project updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted successfully."
  end

  # Manager Only: Assign Users
  def assign_users
    # Managers can assign QA and Developers only
    @users = User.where(role: [ :qa, :developer ])
  end

  def update_users
    # Update assignments for project
    @project.users = User.where(id: params[:user_ids])
    redirect_to projects_path, notice: "Users assigned successfully."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description, user_ids: [])
  end
end
