class MembershipsController < ApplicationController
  before_action :set_membership, only: [:show, :destroy]

  # All memberships of the current user or of a one of the users projects
  # GET /memberships
  def index
    @memberships = Membership.where(user_id: current_user_id)
    users_projects = User.find(current_user_id).projects
    users_projects.each do |project|
      @memberships = (@memberships + Membership.where(project_id: project.id))
    end

    json_response(@memberships.uniq)
  end

  # POST /memberships
  def create
    m_params = membership_params
    # Only create the membership if the current user is member of the project
    project_members = Project.find(m_params[:project_id]).users
    if project_members.exists?(current_user_id)
      if m_params[:user_id].blank? and m_params[:email].present?
        user = User.find_by(email: m_params[:email].strip.downcase)
        user.nil? && json_response({ message: "Email not found." }, :unprocessable_entity) and return

        m_params = m_params.merge(user_id: user.id)
      end
      @membership = Membership.create!(m_params.except(:email))
      json_response(@membership, :created)
    else
      head :unauthorized
    end
  end

  # GET /memberships/:id
  def show
    # Only show the membership if the current user is member of the project
    project_members = @membership.project.users
    if @membership.user_id == current_user_id || project_members.exists?(current_user_id)
      json_response(@membership)
    else
      head :unauthorized
    end
  end

  # DELETE /memberships/:id
  def destroy
    # Only destroy the membership if it is about the current user or if the current user created the project
    # TODO: handle restrictions with roles
    if @membership.user_id == current_user_id || @membership.project.created_by_id == current_user_id
      @membership.destroy
      head :ok
    else
      head :unauthorized
    end
  end

  private

  def membership_params
    params.require(:project_id)
    # params.require(:user_id)
    params.permit(:project_id, :email, :user_id)
  end

  def set_membership
    @membership = Membership.find(params[:id])
  end
end
