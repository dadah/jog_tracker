class Run < ActiveRecord::Base

  belongs_to :user

  validates :run_date, presence: true
  validates :run_time, presence: true
  validates :distance, presence: true
  validates :user, presence: true

end
