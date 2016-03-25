class Tournament < ActiveRecord::Base
  has_many :tables
  has_many :matches
  has_many :rankings

  validates :name, presence: true, uniqueness: true
end
