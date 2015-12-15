require 'rails_helper'

describe AccessToken do

  describe '.create' do

    it 'requires a related user' do
      expect{
        described_class.create!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context 'when a related user exists' do
      let!(:user) do
        User.make!(
          name: 'Test',
          email: 'someemail@email.com',
          password: 'somepassword'
        )
      end

      it 'creates a token with default expiration' do
        created_token = described_class.create user: user
        expect(
          created_token.expires_in
        ).to be > DateTime.now
        expect(
          created_token.token.length
        ).to be > 0
      end
    end

  end
end
