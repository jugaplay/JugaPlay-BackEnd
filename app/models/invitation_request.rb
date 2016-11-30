class InvitationRequest < ActiveRecord::Base
  self.inheritance_column = nil

  belongs_to :user
  has_many :invitation_visits
  has_many :invitation_acceptances

  validates :user, presence: true
  validates :token, presence: true, uniqueness: true, length: { is: 32 }
  validates :type, presence: true, inclusion: { in: InvitationRequestType::ALL }

  def visit(ip)
    InvitationVisit.create!(invitation_request: self, ip: ip)
  end

  def accept(invited_user, ip)
    InvitationAcceptance.create!(invitation_request: self, ip: ip, user: invited_user)
    user.win_coins!(Wallet::COINS_PER_INVITATION)
    TPromotion.friend_invitation!(user: user, detail: "Invitación a #{invited_user.nickname}")
    title = "<b>#{invited_user.nickname}</b> aceptó tu invitación"
    Notification.friend_invitation!(user: user, title: title, text: Wallet::COINS_PER_INVITATION.to_s)
  end
end
