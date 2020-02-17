class AttachmentsController < ApplicationController
  # POST /attachments
  def create
    @attachment_params = attachment_params
    return false unless authorized_for_card? Card.find(@attachment_params[:card_id])
    @attachment = Attachment.create!(@attachment_params)
    json_response(@attachment, :created)
  end

  # DELETE /attachments/:id
  def destroy
    @attachment = Attachment.find(params[:id])
    return false unless authorized_for_card? @attachment.card
    @attachment.destroy
    head :ok
  end

  private

  def attachment_params
    params.require([:card_id, :tag_id])
    params.permit(:card_id, :tag_id)
  end
end
