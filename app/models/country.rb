class Country < ActiveRecord::Base
  belongs_to :language
  validates :name, presence: true, uniqueness: true
end
