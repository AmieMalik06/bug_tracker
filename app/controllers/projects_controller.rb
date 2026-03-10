class ProjectsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource except: [ :index ]

  def index
    if current_user.manager?
      @projects = Project.all
    else
      @projects = current_user.projects
    end
  end

  def show
  end

  def new
  end

  def create
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

  private

  def project_params
    params.require(:project).permit(:title, :description, user_ids: [])
  end
end
