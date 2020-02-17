class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :project, uniqueness: { scope: :user,
                                    message: "Validation failed: User already has a membership with this project." }
end
