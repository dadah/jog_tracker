require 'rails_helper'

describe User do

  describe '.create' do

    let(:valid_params) do
      {
        name: 'Joe',
        email: 'joe_joe@gmail.com',
        password: 'somestring'
      }
    end

    it 'downcases the email before saving' do
      valid_params[:email] = 'CamelCase@gmail.com'
      new_user = described_class.new valid_params
      new_user.save
      expect(
        new_user.email
      ).to eq(
        'camelcase@gmail.com'
      )
    end

    it 'requires a valid email' do
      valid_params[:email] = 'somestring'
      new_user = described_class.new valid_params
      expect(
        new_user.save
      ).to eq(false)
    end

    it 'requires a valid name' do
      valid_params[:name] = 'a'*51
      new_user = described_class.new valid_params
      expect(
        new_user.save
      ).to eq(false)
    end

    it 'has a default role of "user"' do
      new_user = described_class.new valid_params
      expect(
        new_user.role
      ).to eq("user")
    end

    context 'when role is not user' do

      it 'can be a user manager' do
        valid_params[:role] = 'user_manager'
        new_user = described_class.new valid_params
        new_user.save
        expect(
          new_user.role
        ).to eq("user_manager")
      end

      it 'can be an admin' do
        valid_params[:role] = 'admin'
        new_user = described_class.new valid_params
        new_user.save
        expect(
          new_user.role
        ).to eq("admin")
      end

      it 'does not allow random roles' do
        valid_params[:role] = 'random'
        expect{
          new_user = described_class.new valid_params
        }.to raise_error(ArgumentError)
      end

    end

  end

end
