class Explanation < ActiveRecord::Base

  validates :name, presence: true
  validates :detail, presence: true
  has_and_belongs_to_many :users

end
