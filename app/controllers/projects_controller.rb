class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :update, :members, :tags, :lists]

  # GET /projects
  # Returns the current users projects
  def index
    @memberships = Membership.where(user_id: current_user_id).includes(:project)
    project_array = []
    @memberships.each do |membership|
      project_array.push membership.project
    end
    json_response(project_array)
  end

  # POST /projects
  def create
    @project = User.find(current_user_id).created_projects.create!(project_params)
    # update_current_project @project.id # Done in model
    @membership = Membership.create!(project_id: @project.id, user_id: current_user_id)
    json_response({ project: @project, membership: @membership }, :created)
  end

  # GET /projects/:id
  def show
    update_current_project @project.id
    json_response(@project)
  end

  # PUT /projects/:id
  def update
    @project.update(project_params)
    head :ok
  end

  # DELETE /projects/:id
  def destroy
    @project = Project
               .includes([:memberships, tags: [:attachments, :list_attachments], lists:
                   [:list_positions, :list_memberships, :list_attachments, cards: [:assignments, :attachments,
                                                                                   :card_positions]]])
               .find(params[:id])
    @project.destroy
    head :ok
  end

  # GET 'current_project'
  def current
    user = User.find(current_user_id)
    current_project_id = user['current_project_id']
    if current_project_id.nil? and !user.projects.last.nil?
      id = user.memberships.order(:created_at).last.project_id
      update_current_project id
      current_project_id = id
    end
    if current_project_id.nil?
      json_response("", :not_found, "User is not member of a project.")
    else
      json_response(Project.find(current_project_id))
    end
  end

  # GET 'projects/:id/members'
  def members
    project_members = @project.users

    if project_members.exists?(current_user_id)
      json_response(@project.users)
    else
      head :unauthorized
    end
  end

  # GET 'projects/:id/tags'
  def tags
    if @project.users.exists?(current_user_id)
      json_response(@project.tags)
    else
      head :unauthorized
    end
  end

  # GET 'projects/:id/lists'
  def lists
    if @project.users.exists?(current_user_id)
      # render json: @project.lists.includes(:cards), include: [:cards], status: status
      # json_response(@project.lists)
      list_array = []
      @project.lists.includes(:cards).each do |list|
        card_array = []
        list.cards.each do |card|
          card_position = card.card_positions.find_by(user_id: current_user_id)
          position = card_position.position unless card_position.nil?
          card = card.as_json.merge(position: position)
          card_array.push card
        end

        list_position = list.list_positions.find_by(user_id: current_user_id)
        position = list_position.position unless list_position.nil?
        list = list.as_json.merge(position: position, cards: card_array)
        list_array.push list
      end
      render json: list_array, status: :ok
    else
      head :unauthorized
    end
  end

  private

  def project_params
    params.require(:project).permit(:title, :description)
  end

  def set_project
    @project = Project.find(params[:id])
  end
end
