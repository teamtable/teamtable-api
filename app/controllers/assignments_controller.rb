class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:update, :destroy]

  # POST /assignments
  def create
    @assignment_params = assignment_params
    @card = Card.find(@assignment_params[:card_id])
    json_response(Assignment.create!(@assignment_params), :created) if authorized_for_card? @card
  end

  # PUT /assignment/:id
  def update
    @assignment.update(params.permit(:doing))
    head :ok
  end

  # DELETE /assignments/:id
  # TODO: Require role
  def destroy
    return false unless authorized_for_card? @assignment.card
    @assignment.destroy
    head :ok
  end

  private

  def assignment_params
    params.require([:card_id, :user_id])
    params.permit(:card_id, :user_id, :doing)
  end

  def set_assignment
    @assignment = Assignment.find(params[:id])
  end
end
