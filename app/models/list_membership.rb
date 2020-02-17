class ListMembership < ApplicationRecord
  belongs_to :user
  belongs_to :list

  validates :list, uniqueness: { scope: :user,
                                 message: "Validation failed: User already has a membership with this list." }
end
