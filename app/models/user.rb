class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable

  enum role: { manager: 0, developer: 1, qa: 2 }

  has_many :assignments, dependent: :destroy
  has_many :projects, through: :assignments
  has_many :created_bugs, class_name: "Bug", foreign_key: "creator_id"

  # Notifications (using Noticed gem)
  has_many :notifications,
           as: :recipient,
           dependent: :destroy

  # scope for unread notifications
  def unread_notifications
    notifications.where(read_at: nil).order(created_at: :desc)
  end
end
