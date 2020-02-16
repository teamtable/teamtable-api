class ListAttachment < ApplicationRecord
  belongs_to :list
  belongs_to :tag

  validates :list, uniqueness: { scope: :tag,
                                 message: "Validation failed: Tag is already attached to this list." }
end
