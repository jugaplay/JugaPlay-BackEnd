class ClosingTableJob < ActiveRecord::Base
  belongs_to :table

  as_enum :status, pending: 1, finished_successfully: 2, failed: 3

  validates :status, presence: true
  validates :table, presence: true, uniqueness: true
  validates :priority, presence: true, uniqueness: true, numericality: { greater_than: 0, only_integer: true }

  scope :failed, -> { faileds }
  scope :ordered, -> { order(priority: :asc).includes(:table) }

  def self.last_job_priority
    ordered.last.try(:priority) || 0
  end
end
