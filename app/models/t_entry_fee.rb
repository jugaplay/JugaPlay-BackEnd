class TEntryFee < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament
  belongs_to :table
end
