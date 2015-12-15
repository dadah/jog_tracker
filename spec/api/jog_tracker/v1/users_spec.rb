require 'rails_helper'

describe 'Users endpoints', type: :request do

  describe 'GET /api/v1/users/me' do

    context 'when user is not logged in' do
      it 'requires a logged in user' do
        get '/api/v1/users/me', type: :json
        expect(
          response.status
        ).to eq(401)
      end
    end

    context 'when user is logged in' do
      let!(:user) do
        User.make! email: 'someemail@email.com', password: 'somepassword', name: 'test'
      end

      let!(:access_token) do
        AccessToken.make! user: user
      end

      it 'returns the current user' do
        get "/api/v1/users/me?token=#{access_token.token}", type: :json
        expect(
          response.body
        ).to eq(
          {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role
          }.to_json
        )
      end
    end
  end

  describe 'DELETE /api/v1/users/:id' do

    context 'when user is not logged in' do
      it 'requires a logged in user' do
        delete '/api/v1/users/1', type: :json
        expect(
          response.status
        ).to eq(401)
      end
    end

    context 'when user is logged in' do
      let!(:user) do
        User.make! email: 'someemail@email.com', password: 'somepassword', name: 'test'
      end

      let!(:access_token) do
        AccessToken.make! user: user
      end

      it 'returns not found if user does not exist' do
        delete "/api/v1/users/99?token=#{access_token.token}", type: :json
        expect(
          response.status
        ).to eq(404)
      end

      context 'and consulted user exists' do
        let!(:consulted_user) do
          User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'test show'
        end

        it 'forbids if user is not the same as consulted user' do
          delete "/api/v1/users/#{consulted_user.id}?token=#{access_token.token}", type: :json
          expect(
            response.status
          ).to eq(403)
        end

        it 'removes self and tokens' do
          delete "/api/v1/users/#{user.id}?token=#{access_token.token}", type: :json
          expect{
            user.reload
          }.to raise_error(ActiveRecord::RecordNotFound)
          expect{
            access_token.reload
          }.to raise_error(ActiveRecord::RecordNotFound)
        end

        context 'and user is admin' do
          before do
            user.role = 'admin'
            user.save
          end

          it 'deletes user' do
            delete "/api/v1/users/#{consulted_user.id}?token=#{access_token.token}", type: :json
            expect{
              consulted_user.reload
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end

  end

  describe 'PUT /api/v1/users/:id' do

    let(:user_params) do
      {
        name: 'Changed',
        email: 'changed@gmail.com',
        password: '1234599'
      }
    end

    context 'When params are missing or invalid' do
      [:name, :email, :password].each do |param|

        it "requires a #{param}" do
          user_params.delete param
          put '/api/v1/users/1', user_params, type: :json
          expect(
            response.status
          ).to eq(400)
        end
      end

      it 'requires email to be a valid email' do
        user_params[:email] = "somestring"
        put '/api/v1/users/1', user_params, type: :json
        expect(
          response.status
        ).to eq(400)
      end
    end

    context 'when user is not logged in' do
      it 'requires a logged in user' do
        put '/api/v1/users/1', user_params, type: :json
        expect(
          response.status
        ).to eq(401)
      end
    end

    context 'when user is logged in' do
      let!(:user) do
        User.make! email: 'someemail@email.com', password: 'somepassword', name: 'test'
      end

      let!(:access_token) do
        AccessToken.make! user: user
      end

      it 'returns not found if user does not exist' do
        put "/api/v1/users/99?token=#{access_token.token}", user_params, type: :json
        expect(
          response.status
        ).to eq(404)
      end

      context 'and consulted user exists' do
        let!(:consulted_user) do
          User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'test show'
        end

        it 'forbids if user is not the same as consulted user' do
          put "/api/v1/users/#{consulted_user.id}?token=#{access_token.token}", user_params, type: :json
          expect(
            response.status
          ).to eq(403)
        end

        it 'updates self' do
          put "/api/v1/users/#{user.id}?token=#{access_token.token}", user_params, type: :json
          expect(user.reload.email).to eq(user_params[:email])
          expect(user.reload.name).to eq(user_params[:name])
          expect(
            response.body
          ).to eq(
            {
              id: user.id,
              name: user_params[:name],
              email: user_params[:email],
              role: user.role
            }.to_json
          )
        end

        it 'forbids role upgrade' do
          user_params[:role] = 'admin'
          put "/api/v1/users/#{user.id}?token=#{access_token.token}", user_params, type: :json
          expect(
            response.status
          ).to eq(403)
        end

        context 'and user is admin' do
          before do
            user.role = 'admin'
            user.save
          end

          it 'allows role upgrade' do
            user_params[:role] = 'admin'
            put "/api/v1/users/#{consulted_user.id}?token=#{access_token.token}", user_params, type: :json
            expect(
              consulted_user.reload.role
            ).to eq('admin')
          end
        end
      end
    end
  end

  describe 'GET /api/v1/users/:id' do

    context 'when user is not logged in' do
      it 'requires a logged in user' do
        get '/api/v1/users/1', type: :json
        expect(
          response.status
        ).to eq(401)
      end
    end

    context 'when user is logged in' do
      let!(:user) do
        User.make! email: 'someemail@email.com', password: 'somepassword', name: 'test'
      end

      let!(:access_token) do
        AccessToken.make! user: user
      end

      it 'returns not found if user does not exist' do
        get "/api/v1/users/99?token=#{access_token.token}", type: :json
        expect(
          response.status
        ).to eq(404)
      end

      context 'and consulted user exists' do
        let!(:consulted_user) do
          User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'test show'
        end

        it 'forbids if user is not the same as consulted user' do
          get "/api/v1/users/#{consulted_user.id}?token=#{access_token.token}", type: :json
          expect(
            response.status
          ).to eq(403)
        end

        it 'shows self' do
          get "/api/v1/users/#{user.id}?token=#{access_token.token}", type: :json
          expect(
            response.body
          ).to eq(
            {
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.role
            }.to_json
          )
        end

        context 'and user is admin' do
          before do
            user.role = 'admin'
            user.save
          end

          it 'shows any lower user' do
            get "/api/v1/users/#{consulted_user.id}?token=#{access_token.token}", type: :json
            expect(
              response.body
            ).to eq(
              {
                id: consulted_user.id,
                name: consulted_user.name,
                email: consulted_user.email,
                role: consulted_user.role
              }.to_json
            )
          end
        end

        context 'and user is of user manager' do
          before do
            user.role = 'user_manager'
            user.save
          end

          it 'shows any lower user' do
            get "/api/v1/users/#{consulted_user.id}?token=#{access_token.token}", type: :json
            expect(
              response.body
            ).to eq(
              {
                id: consulted_user.id,
                name: consulted_user.name,
                email: consulted_user.email,
                role: consulted_user.role
              }.to_json
            )
          end
        end
      end
    end

  end

  describe 'GET /api/v1/users' do

    context 'when user is not logged in' do
      it 'requires a logged in user' do

        get '/api/v1/users', type: :json
        expect(
          response.status
        ).to eq(401)

      end
    end

    context 'when user is logged in' do
      let!(:user) do
        User.make! email: 'someemail@email.com', password: 'somepassword', name: 'test'
      end
      context 'but does not have enough permissions' do
        let!(:access_token) do
          AccessToken.make! user: user
        end

        it 'forbids regular users' do
          get "/api/v1/users?token=#{access_token.token}", type: :json
          expect(
            response.status
          ).to eq(403)
        end
      end
      context 'and has enough permissions' do
        let!(:access_token) do
          AccessToken.make! user: user
        end

        before do
          user.role = 'user_manager'
          user.save
        end

        it 'returns a list of users with the same or a lesser role' do
          get "/api/v1/users?token=#{access_token.token}", type: :json
          expect(
            response.body
          ).to eq(
            [
              {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role
              }
            ].to_json
          )
        end

        context 'and there are users with a higher role' do
          let!(:admin) do
            User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'admin', role: 'admin'
          end

          it 'hides the higher rated users' do
            get "/api/v1/users?token=#{access_token.token}", type: :json
            expect(
              response.body
            ).to eq(
              [
                {
                  id: user.id,
                  name: user.name,
                  email: user.email,
                  role: user.role
                }
              ].to_json
            )
          end
        end

        context 'but its token is expired' do
          before do
            access_token.expires_in = 1.day.ago
            access_token.save
          end

          it 'requires login' do
            get "/api/v1/users?token=#{access_token.token}", type: :json
            expect(
              response.status
            ).to eq(401)
          end
        end
      end
    end
  end

  describe 'POST /api/v1/users' do

    let(:new_user_params) do
      {
        name: 'Joe',
        email: 'joe@gmail.com',
        password: '12345'
      }
    end

    it 'creates a new user' do
      post '/api/v1/users', new_user_params, type: :json
      expect(User.count).to eq(1)
      expect(
        response.status
      ).to eq(201)
      expect(
        response.body
      ).to eq(
        {
          id: User.last.id,
          name: new_user_params[:name],
          email: new_user_params[:email],
          role: 'user'
        }.to_json
      )
    end

    context 'When params are missing or invalid' do
      [:name, :email, :password].each do |param|

        it "requires a #{param}" do
          new_user_params.delete param
          post '/api/v1/users', new_user_params, type: :json
          expect(
            response.status
          ).to eq(400)
        end
      end

      it 'requires email to be a valid email' do
        new_user_params[:email] = "somestring"
        post '/api/v1/users', new_user_params, type: :json
        expect(
          response.status
        ).to eq(400)
      end
    end
  end

end
