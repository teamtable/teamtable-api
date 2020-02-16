class ListPosition < ApplicationRecord
  belongs_to :list
  belongs_to :user

  validates :list, presence: true,
            uniqueness: { scope: :user, message: "Validation failed: User already has a position saved for this list." }
  validates :position, presence: true,
            uniqueness: { scope: [:user, :list],
                          message: "Validation failed: The position is occupied by another list." }

  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # TODO
  # validate max_position(self.list, self.position)

  # validate check_list_position(self.position, self.list)

  # def check_list_position(position, list)
  #   if position > list.id
  #     errors.add(:position_invalid, "Position must be username has already been taken")
  #   end
  # end

  # def max_position(list, position)
  #   #if List.find(self.list_id).project.lists.length - 1
  #   unless position < list.project.lists.length
  #     errors.add(:position, "Position must be a number less than the number of lists in the project.")
  #   end
  # end
end
