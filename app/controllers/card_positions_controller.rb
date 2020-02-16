class CardPositionsController < ApplicationController

  # PATCH /card-positions
  def update_all
    @card_position_params = card_position_params

    CardPosition.transaction do
      @card_position_params[:card_positions].each do |card_position|
        User.find(current_user_id).card_positions.find_by(card_id: card_position[:card_id])
            .update(position: card_position[:position])
      end

      if @card_position_params.key? :card
        @card = Card.find(@card_position_params[:card][:id])
        return :unauthorized unless authorized_for_card?(@card) && authorized_for_list?(@card.list)
        @card.update(@card_position_params[:card])
        @card.reload
        json_response(@card)
      else
        head :ok
      end
    end
  end

  private

  def card_position_params
    params.require(:card_positions)
    params.permit(card_positions: [:card_id, :position], card: [:id, :list_id])
  end
end
