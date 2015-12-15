require 'rails_helper'

describe 'Auth endpoints', type: :request do

  describe 'POST /api/v1/auth' do

    let!(:user) do
      User.make!(
        name: 'Test',
        email: 'someemail@email.com',
        password: 'somepassword'
      )
    end

    let(:login_params) do
      {
        email: 'someemail@email.com',
        password: 'somepassword'
      }
    end

    it 'logs a user in and returns a session token' do
      expect(
        user.access_tokens.count
      ).to eq(0)
      post '/api/v1/auth', login_params, type: :json
      expect(
        user.access_tokens.count
      ).to eq(1)
      token = user.access_tokens.last
      expect(
        response.body
      ).to eq(
        {
          token: token.token,
          expires_in: token.expires_in
        }.to_json
      )
    end

    context 'when user has logged in before' do

      let!(:access_token) do
        AccessToken.make! user: user
      end

      it 'resets previous access tokens' do
        expect(access_token.expires_in).to be > DateTime.now
        post '/api/v1/auth', login_params, type: :json
        expect(access_token.reload.expires_in).to be < DateTime.now
      end
    end

    context 'when login is invalid' do
      let(:invalid_password) { 'someotherpassword' }
      let(:invalid_email) { 'someotheremail@email.com' }

      it 'forbids when password is invalid' do
        login_params[:password] = invalid_password
        post '/api/v1/auth', login_params, type: :json
        expect(
          response.status
        ).to eq(
          401
        )
      end

      it 'forbids when email is invalid' do
        login_params[:password] = invalid_email
        post '/api/v1/auth', login_params, type: :json
        expect(
          response.status
        ).to eq(
          401
        )
      end

      [:email, :password].each do |param|

        it "requires a #{param}" do
          login_params.delete param
          post '/api/v1/auth', login_params, type: :json
          expect(
            response.status
          ).to eq(400)
        end
      end
    end

  end

end
