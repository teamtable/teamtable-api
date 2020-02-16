class ListPositionsController < ApplicationController

  # PATCH /list-positions
  def update_all
    ListPosition.transaction do
      list_position_params[:list_positions].each do |list_position|
        User.find(current_user_id).list_positions.find_by(list_id: list_position[:list_id])
            .update(position: list_position[:position])
      end
    end
    head :ok
  end

  private

  def list_position_params
    params.require(:list_positions)
    params.permit(list_positions: [:list_id, :position])
  end
end
