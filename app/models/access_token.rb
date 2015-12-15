class AccessToken < ActiveRecord::Base
  belongs_to :user
  before_validation do
    generate_token
  end

  validates :user, presence: true
  validates :token, presence: true
  validates :expires_in, presence: true

  def generate_token
    SecureRandom.urlsafe_base64(32).tap do |token|
      self.token = token
    end unless token.present?
    self.expires_in = Settings.expiration_in_seconds.seconds.from_now unless expires_in.present?
  end
end
