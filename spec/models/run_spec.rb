require 'rails_helper'

describe Run do

  describe '.create' do

    let(:params) do
      {
        run_date: DateTime.now,
        run_time: 2000,
        distance: 3000
      }
    end

    it 'requires a related user' do
      expect{
        described_class.create! params
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
        expect(Run.count).to eq(0)
        params[:user] = user
        run = described_class.create params
        expect(Run.count).to eq(1)
      end
    end

  end
end
