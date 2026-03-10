class Project < ApplicationRecord
  has_many :bugs, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments
end