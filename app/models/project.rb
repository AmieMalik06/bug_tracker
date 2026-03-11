class Project < ApplicationRecord
  has_many :bugs, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments

  # Only these fields are searchable
  def self.ransackable_attributes(auth_object = nil)
    %w[id title description created_at updated_at]
  end

  # Optional: allow searching by associated users
  def self.ransackable_associations(auth_object = nil)
    %w[users]
  end
end
