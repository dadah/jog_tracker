class User < ActiveRecord::Base

  has_many :access_tokens, inverse_of: :user, dependent: :destroy
  has_many :runs, inverse_of: :user, dependent: :destroy

  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: Settings.valid_email_regex },
                    uniqueness: { case_sensitive: false }
  validates :role, presence: true
  enum role: [ :user, :user_manager, :admin ]
  has_secure_password

  def reset_tokens
    access_tokens.update_all expires_in: 1.second.ago
  end
end
