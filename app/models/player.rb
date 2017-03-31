class Player < ActiveRecord::Base
  belongs_to :team
  has_many :player_stats
  has_many :player_selections
  has_many :plays, through: :player_selections
  has_one :data_factory_players_mapping, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :description, presence: true
  validates :birthday, presence: true
  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :position, presence: true, inclusion: { in: Position::ALL }
  validates :nationality, presence: true, inclusion: { in: Country::ALL }
  validates :team, uniqueness: { scope: [:first_name, :last_name, :position] }

  def name
    "#{first_name} #{last_name}"
  end

  def team_name_if_none(&if_none_block)
    return if_none_block.call if team.nil?
    team.name
  end

  def data_factory_id_if_none(&if_none_block)
    return if_none_block.call if data_factory_players_mapping.nil?
    data_factory_players_mapping.data_factory_id
  end
end
