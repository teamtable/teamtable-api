class CardPosition < ApplicationRecord
  belongs_to :card
  belongs_to :user

  validates :card, presence: true,
            uniqueness: { scope: :user, message: "Validation failed: User already has a position saved for this card." }
  validates :position, presence: true,
            uniqueness: { scope: [:user, :card],
                          message: "Validation failed: The position is occupied by another card." }

  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # TODO
  # validate max_position(self.card, self.position)

  # validate check_card_position(self.position, self.card)

  # def check_card_position(position, card)
  #   if position > card.id
  #     errors.add(:position_invalid, "Position must be username has already been taken")
  #   end
  # end

  # def max_position(card, position)
  #   #if Card.find(self.card_id).project.cards.length - 1
  #   unless position < card.project.cards.length
  #     errors.add(:position, "Position must be a number less than the number of cards in the project.")
  #   end
  # end
end
