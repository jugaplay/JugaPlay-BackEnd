class TelephoneUpdateRequest < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true
  validates :telephone, format: /\A\d+\Z/, presence: true
  validates :validation_code, presence: true, uniqueness: { scope: :user }, length: { is: 6 }

  def apply!
    user.update_attributes!(telephone: telephone)
    update_attributes(applied: true)
  end
end
