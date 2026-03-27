class Bug < ApplicationRecord
  belongs_to :project
  belongs_to :creator, class_name: "User"
  belongs_to :assigned_user, class_name: "User", optional: true

  # Enums
  enum bug_type: { feature: 0, bug: 1 }
  enum status: { new: 0, started: 1, completed: 2, resolved: 3 }, _prefix: :status

  # File Upload
  mount_uploader :screenshot, ScreenshotUploader

  # Validations
  validates :title, presence: true, uniqueness: { scope: :project_id }
  validates :status, presence: true
  validates :bug_type, presence: true
  validate :screenshot_format

  # ------------------------------
  # Ransack Searchable Attributes
  # ------------------------------
  def self.ransackable_attributes(auth_object = nil)
    %w[title bug_type]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end


  # Dynamic Statuses Based on Type
  def available_statuses(for_type: nil)
    type_to_use = for_type || bug_type || "bug"
    case type_to_use
    when "feature"
      %w[new started completed]
    when "bug"
      %w[new started resolved]
    else
      []
    end
  end

  # Track Previous Assignment (for Notifications)
  attr_accessor :previous_assigned_user_id
  before_update :store_previous_assignment

  private

  def store_previous_assignment
    self.previous_assigned_user_id = assigned_user_id_was
  end

  # Screenshot Validation
  def screenshot_format
    return unless screenshot.present? && screenshot.file.present?
    allowed_types = [ "image/png", "image/gif" ]
    unless allowed_types.include?(screenshot.file.content_type)
      errors.add(:screenshot, "must be a PNG or GIF")
    end
  end
end
