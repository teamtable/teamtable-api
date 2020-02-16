class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :card

  validates :card, uniqueness: { scope: :user,
                                 message: "Validation failed: User is already assigned to this card." }
end
