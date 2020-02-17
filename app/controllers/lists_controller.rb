class ListsController < ApplicationController
  before_action :set_list, only: [:show, :update, :members, :cards, :tags, :update_position]

  # GET /lists
  # Returns the lists of the current users projects
  def index
    list_array = []
    user = User.find(current_user_id)
    Project.find(user.current_project_id).lists.includes(:cards).each do |list|
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
  end

  # POST /lists
  def create
    params[:list].require(:project_id)
    @list = User.find(current_user_id).created_lists.create!(list_params)

    @list.reload
    list_position = @list.list_positions.find_by(user_id: current_user_id)
    position = list_position.position unless list_position.nil?
    @list = @list.as_json.merge(position: position)
    render json: @list, status: :created
  end

  # GET /lists/:id
  def show
    return false unless authorized_for_list? @list
    @list = @list.as_json.merge(position: @list.list_positions.find_by(user_id: current_user_id).position)
    render json: @list, status: status
  end

  # PUT /lists/:id
  def update
    return false unless authorized_for_list? @list
    @list.update(list_params)
    head :ok
  end

  # DELETE /lists/:id
  def destroy
    return false unless authorized_for_list? List.find(params[:id])
    @list = List.includes([:list_positions, :list_memberships, :list_attachments,
                           cards: [:assignments, :attachments, :card_positions]]).find(params[:id])
    project = @list.project
    position = @list.list_positions.find_by(user_id: current_user_id).position
    @list.destroy

    changed_list_positions = []
    project.lists.each do |list|
      list.list_positions.includes(:user).where("position > ?", position).order(:position).each do |list_position|
        list_position.update(position: list_position[:position] - 1)
        changed_list_positions.push list_position
      end
    end
    json_response changed_list_positions
  end

  # GET 'lists/:id/members'
  def members
    json_response(@list.users) if authorized_for_list? @list
  end

  # GET 'lists/:id/cards'
  def cards
    json_response(@list.cards) if authorized_for_list? @list
  end

  # GET 'lists/:id/tags'
  def tags
    json_response(@list.tags) if authorized_for_list? @list
  end

  # PUT /lists/:id/position
  def update_position
    return false unless authorized_for_list? @list
    params.require(:position)
    @list.list_positions.find_by(user_id: current_user_id).update(params.permit(:position))
    head :ok
  end

  private

  def list_params
    params.require(:list).permit(:title, :description, :project_id)
  end

  def set_list
    @list = List.find(params[:id])
  end
end
