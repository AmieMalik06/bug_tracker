class Notification < ApplicationRecord
  belongs_to :recipient, polymorphic: true
  belongs_to :target, polymorphic: true, optional: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }

  def mark_as_read
    update(read_at: Time.current) unless read?
  end

  def read?
    read_at.present?
  end
end
