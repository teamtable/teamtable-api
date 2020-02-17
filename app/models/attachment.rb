class Attachment < ApplicationRecord
  belongs_to :card
  belongs_to :tag

  validates :card, uniqueness: { scope: :tag,
                                 message: "Validation failed: Tag is already attached to this card." }
end
