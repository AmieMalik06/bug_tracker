class ProjectsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource except: [ :index ]

  def index
    # Base projects depending on user role
    base_projects = current_user.manager? ? Project.all : current_user.projects.all

    # Ransack search
    @q = base_projects.ransack(params[:q])
    @projects = @q.result.includes(:users)
  end

  def show
  end

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

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to projects_path, notice: "Project updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted."
  end

  # MANAGER ONLY
  def assign_users
    @users = User.where(role: [ :qa, :developer ])
  end

  def update_users
    @project.users = User.where(id: params[:user_ids])
    redirect_to projects_path, notice: "Users assigned successfully."
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, user_ids: [])
  end
end
