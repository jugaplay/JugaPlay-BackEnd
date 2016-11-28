class InvitationRequest < ActiveRecord::Base
  self.inheritance_column = nil

  belongs_to :user
  has_many :invitation_visits
  has_many :invitation_acceptances

  validates :user, presence: true
  validates :token, presence: true, uniqueness: true, length: { is: 32 }
  validates :type, presence: true, inclusion: { in: InvitationRequestType::ALL }
end
