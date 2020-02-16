class Card < ApplicationRecord
  before_create :unique_id_within_cards_and_lists
  after_create :create_positions

  # Model associations
  belongs_to :list
  belongs_to :created_by, class_name: "User", inverse_of: "created_cards"
  belongs_to :completed_by, class_name: "User", inverse_of: "completed_cards", optional: true

  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments

  has_many :attachments, dependent: :destroy
  has_many :tags, through: :attachments

  has_many :card_positions, dependent: :destroy

  # validations
  validates :list_id, presence: true
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 30_000 }
  validates :state, inclusion: 0..2
  validates :priority, inclusion: 0..10

  private

  # Necessary, because the drag & drop library used in the react view requires unique ids among
  # all Draggables (lists and cards) in a DragDropContext
  # ( https://github.com/atlassian/react-beautiful-dnd/blob/master/docs/guides/identifiers.md#ids-must-be-unique )
  # An alternative would have been to add a prefix to the ids in the react view, but willing to avoid
  # asynchronicity we chose to ensure the uniqueness in the rails application.
  def unique_id_within_cards_and_lists
    card_with_max_id = Card.order(:id).last
    list_with_max_id = List.order(:id).last
    max_card_id = card_with_max_id.nil? ? 0 : card_with_max_id.id
    max_list_id = list_with_max_id.nil? ? 0 : list_with_max_id.id
    self.id = [max_card_id + 1, max_list_id + 1].max
  end

  def create_positions
    position = list.cards.length - 1
    list.project.users.each do |user|
      card_positions.create!(card_id: id, user_id: user.id, position: position)
    end
  end
end
