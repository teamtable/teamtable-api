class Tag < ApplicationRecord
  belongs_to :project

  has_many :attachments, dependent: :destroy
  has_many :cards, through: :attachments

  has_many :list_attachments, dependent: :destroy
  has_many :lists, through: :list_attachments

  validates :name, presence: true, length: { maximum: 23 },
            uniqueness: { case_sensitive: false, scope: :project,
                          message: "Validation failed: Project already has a tag with this name." }

  VALID_COLOR_HEX_CODE_REGEX = /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/i
  validates :color, presence: true,
            format: { with: VALID_COLOR_HEX_CODE_REGEX }
end
