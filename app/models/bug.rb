class Bug < ApplicationRecord
  belongs_to :project
  belongs_to :creator, class_name: "User"
  belongs_to :assigned_user, class_name: "User", optional: true

  # Allow these fields to be searchable with Ransack
  def self.ransackable_attributes(auth_object = nil)
    [
      "assigned_user_id",
      "bug_type",
      "created_at",
      "creator_id",
      "deadline",
      "description",
      "id",
      "project_id",
      "screenshot",
      "status",
      "title",
      "updated_at"
    ]
  end

  enum bug_type: { feature: 0, bug: 1 }, _prefix: true
  enum status: {
    new_feature: 0,
    new_bug: 1,
    started: 2,
    completed: 3,
    resolved: 4
  }, _prefix: true


  mount_uploader :screenshot, ScreenshotUploader


  validates :title, presence: true, uniqueness: { scope: :project_id }
  validates :status, presence: true
  validates :bug_type, presence: true
  validate :screenshot_format

  def available_statuses
    case bug_type
    when "feature"
      { "New" => "new_feature", "Started" => "started", "Completed" => "completed" }
    when "bug"
      { "New" => "new_bug", "Started" => "started", "Resolved" => "resolved" }
    else
      {}
    end
  end

  private

  def screenshot_format
    return unless screenshot.present? && screenshot.file.present?

    acceptable_types = [ "image/png", "image/gif" ]
    unless acceptable_types.include?(screenshot.file.content_type)
      errors.add(:screenshot, "must be a PNG or GIF file")
    end
  end
end
