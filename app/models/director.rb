class Director < ActiveRecord::Base
  has_one :team

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :description, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end