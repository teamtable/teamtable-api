class ListMembershipsController < ApplicationController
  before_action :set_list_membership, only: [:show, :destroy]

  # All list_memberships of the current user or of a one of the users lists
  # GET /list_memberships
  def index
    @list_memberships = ListMembership.where(user_id: current_user_id)
    users_projects = User.includes(projects: :lists).find(current_user_id).projects
    users_projects.each do |project|
      project.lists.each do |list|
        @list_memberships = (@list_memberships + ListMembership.where(list_id: list.id))
      end
    end

    json_response(@list_memberships.uniq)
  end

  # POST /list_memberships
  def create
    m_params = list_membership_params
    # Only create the list_membership if the current user is member of the list
    list_members = List.find(m_params[:list_id]).users
    if list_members.exists?(current_user_id)
      if m_params[:user_id].blank? and m_params[:email].present?
        user = User.find_by(email: m_params[:email].strip.downcase)
        user.nil? && json_response({ message: "Email not found." }, :unprocessable_entity) and return

        m_params = m_params.merge(user_id: user.id)
      end
      @list_membership = ListMembership.create!(m_params.except(:email))
      json_response(@list_membership, :created)
    else
      head :unauthorized
    end
  end

  # GET /list_memberships/:id
  def show
    # Only show the list_membership if the current user is member of the list
    list_members = @list_membership.list.users
    if @list_membership.user_id == current_user_id || list_members.exists?(current_user_id)
      json_response(@list_membership)
    else
      head :unauthorized
    end
  end

  # DELETE /list_memberships/:id
  def destroy
    # Only destroy the list_membership if it is about the current user or if the current user created the list
    # TODO: handle restrictions with roles
    if @list_membership.user_id == current_user_id || @list_membership.list.created_by_id == current_user_id
      @list_membership.destroy
      head :ok
    else
      head :unauthorized
    end
  end

  private

  def list_membership_params
    params.require(:list_id)
    # params.require(:user_id)
    params.permit(:list_id, :email, :user_id)
  end

  def set_list_membership
    @list_membership = ListMembership.find(params[:id])
  end
end
