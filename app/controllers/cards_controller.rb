class CardsController < ApplicationController
  before_action :set_card, only: [:show, :update, :assigned_users, :doing_users]

  # GET /cards
  # Returns all cards of the users projects
  def index
    card_array = []
    User.find(current_user_id).projects.includes(lists: [:cards]).each do |project|
      project.lists.each do |list|
        list.cards.each do  |card|
          card_position = card.card_positions.find_by(user_id: current_user_id)
          position = card_position.position unless card_position.nil?
          card = card.as_json.merge(position: position)
          card_array.push card
        end
      end
    end
    render json: card_array, status: :ok
  end

  # POST /cards
  def create
    # TODO: check if authorized for list
    params[:card].require(:list_id)
    return false unless authorized_for_list? List.find params[:card][:list_id]
    @card = User.find(current_user_id).created_cards.create!(card_params)

    card_position = @card.card_positions.find_by(user_id: current_user_id)
    position = card_position.position unless card_position.nil?
    @card = @card.as_json.merge(position: position)
    render json: @card, status: :created
  end

  # GET /cards/:id
  def show
    return false unless authorized_for_card? @card
    @card = @card.as_json.merge(position: @card.card_positions.find_by(user_id: current_user_id).position)
    render json: @card, status: status
  end

  # PUT /cards/:id
  def update
    @card_params = card_params
    return false if !authorized_for_card?(@card) or (@card_params.key?(:list_id) and
                    !authorized_for_list?(List.find(@card_params[:list_id])))

    @card_params["completed_by_id"] = nil
    @card_params["completed_at"] = nil
    @card_params["state"] = parse_state @card_params["state"] unless @card_params["state"].nil?
    if @card_params["state"] == 2
      @card_params["completed_by_id"] = current_user_id
      @card_params["completed_at"] = Time.zone.now
    end

    @card.update(@card_params)
    head :ok
  end

  # DELETE /cards/:id
  def destroy
    return false unless authorized_for_card? Card.find(params[:id])
    @card = Card.includes([:card_positions, :assignments, :attachments]).find(params[:id])
    position = @card.card_positions.find_by(user_id: current_user_id).position
    list = @card.list
    @card.destroy

    changed_card_positions = []
    list.cards.each do |card|
      card.card_positions.includes(:user).where("position > ?", position).order(:position).each do |card_position|
        card_position.update(position: card_position[:position] - 1)
        changed_card_positions.push card_position
      end
    end
    json_response changed_card_positions
  end

  # GET 'cards/:id/assigned_users'
  def assigned_users
    json_response(@card.users) if authorized_for_card? @card
  end

  # GET 'cards/:id/doing_users'
  def doing_users
    return false unless authorized_for_card? @card
    json_response(@card.assignments.includes(:user).select { |assignment| assignment.doing == true }.map(&:user))
  end

  private

  def card_params
    params.require(:card).permit(:title, :description, :priority, :deadline, :state, :list_id)
  end

  def set_card
    @card = Card.find(params[:id])
  end

  def parse_state(state)
    case state
      when "todo"
        state = 0
      when "doing"
        state = 1
      when "done"
        state = 2
    end
    state
  end
end
