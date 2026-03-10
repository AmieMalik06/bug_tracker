
class Bug < ApplicationRecord
  belongs_to :project
  belongs_to :creator, class_name: "User"

  enum bug_type: { feature: 0, bug: 1 }


  enum status: {
    new_feature: 0,   # internal key for "new" feature
    new_bug: 1,       # internal key for "new" bug
    started: 2,
    completed: 3,     # only for feature
    resolved: 4       # only for bug
  }

  validates :title, presence: true, uniqueness: { scope: :project_id }
  validates :status, presence: true
  validates :bug_type, presence: true
end
