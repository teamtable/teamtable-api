class TagsController < ApplicationController
  before_action :set_tag, only: [:show, :update, :destroy, :cards]

  # GET /tags
  # def index
  # end

  # POST /tags
  def create
    @tag = Tag.create!(tag_params)
    json_response(@tag, :created)
  end

  # GET /tags/:id
  def show
    json_response(@tag)
  end

  # PUT /tags/:id
  def update
    @tag.update(tag_params)
    head :ok
  end

  # DELETE /tags/:id
  def destroy
    @tag = Tag.includes([:attachments, :list_attachments]).find(params[:id])
    return false unless authorized_for_tag? @tag
    @tag.destroy
    head :ok
  end

  # GET 'tags/:id/cards'
  def cards
    json_response(@tag.cards) if authorized_for_tag? @tag
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :color, :project_id)
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end
end
