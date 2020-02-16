class UsersController < ApplicationController
  before_action :set_user, only: [:completed_cards, :assigned_cards, :doing_cards]

  # GET 'users/:id/created_cards'
  def created_cards
    @cards = Card.where(created_by_id: params[:id]).includes(list: [:project])
                 .select { |card| card.list.project.users.exists?(current_user_id) }
    json_response(@cards)
  end

  # GET 'users/:id/completed_cards'
  def completed_cards
    @cards = Card.where(completed_by_id: params[:id]).includes(list: [:project])
                 .select { |card| card.list.project.users.exists?(current_user_id) }
    json_response(@cards)
  end

  # GET 'users/:id/assigned_cards'
  def assigned_cards
    @cards = @user.cards.includes(list: [:project]).select { |card| card.list.project.users.exists?(current_user_id) }
    json_response(@user.cards)
  end

  # GET 'users/:id/doing_cards'
  def doing_cards
    @cards = @user.assignments.includes(card: [list: [:project]]).select { |assignment| assignment.doing == true }
                  .map(&:card).select { |card| card.list.project.users.exists?(current_user_id) }
    json_response(@cards)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
