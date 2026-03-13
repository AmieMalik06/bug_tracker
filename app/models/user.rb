class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable


  enum role: { manager: 0, developer: 1, qa: 2 }


  has_many :assignments, dependent: :destroy
  has_many :projects, through: :assignments

  has_many :created_bugs, class_name: "Bug", foreign_key: "creator_id"

  acts_as_target    # allows user to receive notifications
end
