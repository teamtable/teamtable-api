class Project < ApplicationRecord
  # Model associations
  belongs_to :created_by, class_name: "User", inverse_of: "created_projects"

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  has_many :tags, dependent: :destroy

  has_many :lists, dependent: :destroy

  # validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 30_000 }
  validates :created_by_id, presence: true

  has_many :active_users, class_name: "User", foreign_key: "current_project_id", inverse_of: "current_project",
           dependent: :nullify

  after_save :update_current_project

  private

  def update_current_project
    created_by.update_current_project id
  end
end
