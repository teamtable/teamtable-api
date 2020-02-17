class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable, :rememberable and :omniauthable
  devise :database_authenticatable, :registerable, :lockable,
         :recoverable, :validatable, :confirmable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist

  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  has_many :created_projects, class_name: "Project", foreign_key: "created_by_id", inverse_of: 'created_by',
           dependent: :nullify

  has_many :memberships, dependent: :destroy
  has_many :projects, through: :memberships

  has_many :created_lists, class_name: "List", foreign_key: "created_by_id", inverse_of: 'created_by',
           dependent: :nullify

  has_many :list_memberships, dependent: :destroy
  has_many :list, through: :list_memberships

  has_many :created_cards, class_name: "Card", foreign_key: "created_by_id", inverse_of: 'created_by',
           dependent: :nullify

  has_many :completed_cards, class_name: "Card", foreign_key: "completed_by_id", inverse_of: 'completed_by',
           dependent: :nullify

  has_many :assignments, dependent: :destroy
  has_many :cards, through: :assignments

  has_many :list_positions, dependent: :destroy
  has_many :card_positions, dependent: :destroy

  belongs_to :current_project, class_name: "Project", inverse_of: "active_users", optional: true

  def update_current_project(project_id)
    update(current_project_id: project_id)
  end
end
