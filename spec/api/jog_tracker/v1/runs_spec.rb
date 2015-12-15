require 'rails_helper'

describe 'Runs endpoints', type: :request do

  let!(:user) do
    User.make! email: 'someemail@email.com', password: 'somepassword', name: 'test'
  end

  let!(:access_token) do
    AccessToken.make! user: user
  end

  describe 'GET /api/v1/runs' do

    context 'when user is not logged in' do
      it 'requires a logged in user' do
        get '/api/v1/runs/1', type: :json
        expect(
          response.status
        ).to eq(401)
      end
    end

    context 'when user is logged in' do

      let!(:admin) do
        User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'other test', role: 'admin'
      end

      let!(:user_manager) do
        User.make! email: 'someotherotheremail@email.com', password: 'someotherotherpassword', name: 'other other test', role: 'user_manager'
      end

      let!(:run) do
        Run.make! user: user,
          run_date: 10.days.ago,
          run_time: 6200,
          distance: 10000
      end

      let!(:admin_run) do
        Run.make! user: admin,
          run_date: 5.days.ago,
          run_time: 6200,
          distance: 10000
      end

      let!(:user_manager_run) do
        Run.make! user: user_manager,
          run_date: 1.day.ago,
          run_time: 6200,
          distance: 10000
      end

      context 'and user is a user' do
        it 'gets only own runs' do
          get "/api/v1/runs?token=#{access_token.token}", type: :json
          runs = JSON.parse(response.body)
          expect(runs.count).to eq(1)
          expect(runs.first["user"]["id"]).to eq(user.id)
        end
      end

      context 'and user is a user manager' do
        before do
          access_token.user = user_manager
          access_token.save
        end

        it 'gets own runs and user runs' do
          get "/api/v1/runs?token=#{access_token.token}", type: :json
          runs = JSON.parse(response.body)
          expect(runs.count).to eq(2)
        end
      end

      context 'and user is admin' do
        before do
          access_token.user = admin
          access_token.save
        end

        it 'gets all runs' do
          get "/api/v1/runs?token=#{access_token.token}", type: :json
          runs = JSON.parse(response.body)
          expect(runs.count).to eq(3)
        end

        it 'filters by date' do
          get "/api/v1/runs?token=#{access_token.token}&starts_at=#{6.days.ago.to_date}&ends_at=#{4.days.ago.to_date}", type: :json
          runs = JSON.parse(response.body)
          expect(runs.count).to eq(1)
          expect(runs.first["id"]).to eq(admin_run.id)
        end

        it 'filters by user' do
          get "/api/v1/runs?token=#{access_token.token}&user_id=#{user.id}", type: :json
          runs = JSON.parse(response.body)
          expect(runs.count).to eq(1)
          expect(runs.first["id"]).to eq(run.id)
        end
      end

    end
  end

  describe 'GET /api/v1/runs/:run_id' do

    context 'when user is not logged in' do
      it 'requires a logged in user' do
        get '/api/v1/runs/1', type: :json
        expect(
          response.status
        ).to eq(401)
      end
    end

    context 'when user is logged in' do
      it 'returns not found if run does not exist' do
        get "/api/v1/runs/1?token=#{access_token.token}", type: :json
        expect(
          response.status
        ).to eq(404)
      end

      context 'and run exists' do
        let!(:run) do
          Run.make! user: user,
            run_date: DateTime.now,
            run_time: 6200,
            distance: 10000
        end

        it 'returns the run' do
          get "/api/v1/runs/#{run.id}?token=#{access_token.token}", type: :json
          expect(
            response.body
          ).to eq(
            {
              id: run.id,
              run_date: run.run_date.utc.iso8601,
              run_time: run.run_time,
              distance: run.distance,
              user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role
              }
            }.to_json
          )
        end

        context 'and getter is a user manager' do
          let!(:other_user) do
            User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'other test', role: 'user_manager'
          end

          before do
            user.role = 'user_manager'
            user.save
            run.user = other_user
            run.save
          end

          it 'forbids access if user does not own run' do
            get "/api/v1/runs/#{run.id}?token=#{access_token.token}", type: :json
            expect(
              response.status
            ).to eq(403)
          end
        end

        context 'and getter is admin' do
          let!(:other_user) do
            User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'other test'
          end

          before do
            user.role = 'admin'
            user.save
            run.user = other_user
            run.save
          end

          it 'gets the run' do
            get "/api/v1/runs/#{run.id}?token=#{access_token.token}", type: :json
            expect(
              response.body
            ).to eq(
              {
                id: run.id,
                run_date: run.run_date.utc.iso8601,
                run_time: run.run_time,
                distance: run.distance,
                user: {
                  id: other_user.id,
                  name: other_user.name,
                  email: other_user.email,
                  role: other_user.role
                }
              }.to_json
            )
          end
        end
      end
    end

  end

  describe 'DELETE /api/v1/runs/:run_id' do

    context 'when user is not logged in' do
      it 'requires a logged in user' do
        delete '/api/v1/runs/1', type: :json
        expect(
          response.status
        ).to eq(401)
      end
    end

    context 'when user is logged in' do
      it 'returns not found if run does not exist' do
        delete "/api/v1/runs/1?token=#{access_token.token}", type: :json
        expect(
          response.status
        ).to eq(404)
      end

      context 'and run exists' do
        let!(:run) do
          Run.make! user: user,
            run_date: DateTime.now,
            run_time: 6200,
            distance: 10000
        end

        it 'destroys the run' do
          delete "/api/v1/runs/#{run.id}?token=#{access_token.token}", type: :json
          expect{
            run.reload
          }.to raise_error(ActiveRecord::RecordNotFound)
        end

        context 'and destroyer is a user manager' do
          let!(:other_user) do
            User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'other test', role: 'user_manager'
          end

          before do
            user.role = 'user_manager'
            user.save
            run.user = other_user
            run.save
          end

          it 'forbids destruction if user does not own run' do
            delete "/api/v1/runs/#{run.id}?token=#{access_token.token}", type: :json
            expect(
              response.status
            ).to eq(403)
          end
        end

        context 'and creator is admin' do
          let!(:other_user) do
            User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'other test'
          end

          before do
            user.role = 'admin'
            user.save
            run.user = other_user
            run.save
          end

          it 'deletes the run' do
            delete "/api/v1/runs/#{run.id}?token=#{access_token.token}", type: :json
            expect{
              run.reload
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end

  describe 'PUT /api/v1/runs/:run_id' do

    let(:run_params) do
      {
        run_date: DateTime.now,
        run_time: 7200,
        distance: 20000
      }
    end

    context 'when user is not logged in' do
      it 'requires a logged in user' do
        put '/api/v1/runs/1', run_params, type: :json
        expect(
          response.status
        ).to eq(401)
      end
    end

    context 'When params are missing or invalid' do
      [:run_date, :run_time, :distance].each do |param|
        it "requires a #{param}" do
          run_params.delete param
          put '/api/v1/runs/1', run_params, type: :json
          expect(
            response.status
          ).to eq(400)
        end
      end
    end

    context 'when user is logged in' do
      it 'returns not found if run does not exist' do
        put "/api/v1/runs/1?token=#{access_token.token}", run_params, type: :json
        expect(
          response.status
        ).to eq(404)
      end

      context 'and run exists' do
        let!(:run) do
          Run.make! user: user,
            run_date: DateTime.now,
            run_time: 6200,
            distance: 10000
        end

        it 'updates the run' do
          put "/api/v1/runs/#{run.id}?token=#{access_token.token}", run_params, type: :json
          expect(
            response.body
          ).to eq(
            {
              id: run.id,
              run_date: run_params[:run_date].to_time.iso8601,
              run_time: run_params[:run_time],
              distance: run_params[:distance],
              user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role
              }
            }.to_json
          )
        end

        context 'and run owner is being changed' do
          it 'returns not found if other user is user' do
            run_params[:user_id] = 99
            put "/api/v1/runs/#{run.id}?token=#{access_token.token}", run_params, type: :json
            expect(
              response.status
            ).to eq(403)
          end
        end

        context 'and updater is a user manager' do
          before do
            user.role = 'user_manager'
            user.save
          end

          let!(:other_user) do
            User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'other test', role: 'user_manager'
          end

          it 'forbids creation of run for different user if its role is not user' do
            run_params[:user_id] = other_user.id
            put "/api/v1/runs/#{run.id}?token=#{access_token.token}", run_params, type: :json
            expect(
              response.status
            ).to eq(403)
          end

          context 'but run is owned by different user' do
            before do
              run.user = other_user
              run.save
            end

            it 'forbids update' do
              put "/api/v1/runs/#{run.id}?token=#{access_token.token}", run_params, type: :json
              expect(
                response.status
              ).to eq(403)
            end
          end
        end

        context 'and creator is admin' do
          before do
            user.role = 'admin'
            user.save
          end

          it 'returns not found if other user does not exist' do
            run_params[:user_id] = 99
            put "/api/v1/runs/#{run.id}?token=#{access_token.token}", run_params, type: :json
            expect(
              response.status
            ).to eq(404)
          end

          context 'and run user exists' do
            let!(:other_user) do
              User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'other test'
            end

            it 'updates the run' do
              run_params[:user_id] = other_user.id
              put "/api/v1/runs/#{run.id}?token=#{access_token.token}", run_params, type: :json
              expect(
                response.body
              ).to eq(
                {
                  id: run.id,
                  run_date: run_params[:run_date].to_time.iso8601,
                  run_time: run_params[:run_time],
                  distance: run_params[:distance],
                  user: {
                    id: other_user.id,
                    name: other_user.name,
                    email: other_user.email,
                    role: other_user.role
                  }
                }.to_json
              )
            end
          end
        end
      end
    end
  end

  describe 'POST /api/v1/runs' do

    let(:run_params) do
      {
        run_date: DateTime.now,
        run_time: 7200,
        distance: 20000
      }
    end

    context 'when user is not logged in' do
      it 'requires a logged in user' do
        post '/api/v1/runs', run_params, type: :json
        expect(
          response.status
        ).to eq(401)
      end
    end

    context 'When params are missing or invalid' do
      [:run_date, :run_time, :distance].each do |param|
        it "requires a #{param}" do
          run_params.delete param
          post '/api/v1/runs', run_params, type: :json
          expect(
            response.status
          ).to eq(400)
        end
      end
    end

    context 'when user is logged in' do
      it 'creates a new run for current user' do
        expect(Run.count).to eq(0)
        post "/api/v1/runs?token=#{access_token.token}", run_params, type: :json
        expect(Run.count).to eq(1)
        expect(
          response.body
        ).to eq(
          {
            id: Run.last.id,
            run_date: run_params[:run_date].to_time.iso8601,
            run_time: run_params[:run_time],
            distance: run_params[:distance],
            user: {
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.role
            }
          }.to_json
        )
      end

      it 'does not allow a run for a different user' do
        run_params[:user_id] = 99
        post "/api/v1/runs?token=#{access_token.token}", run_params, type: :json
        expect(
          response.status
        ).to eq(403)
      end
    end

    context 'and creator is a user manager' do
      before do
        user.role = 'user_manager'
        user.save
      end

      let!(:other_user) do
        User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'other test', role: 'user_manager'
      end

      it 'forbids creation of run for different user if its role is not user' do
        run_params[:user_id] = other_user.id
        post "/api/v1/runs?token=#{access_token.token}", run_params, type: :json
        expect(
          response.status
        ).to eq(403)
      end
    end

    context 'and creator is admin' do
      before do
        user.role = 'admin'
        user.save
      end

      it 'returns not found if other user does not exist' do
        run_params[:user_id] = 99
        post "/api/v1/runs?token=#{access_token.token}", run_params, type: :json
        expect(
          response.status
        ).to eq(404)
      end

      context 'and run user exists' do
        let!(:other_user) do
          User.make! email: 'someotheremail@email.com', password: 'someotherpassword', name: 'other test'
        end

        it 'creates a new run for the user' do
          run_params[:user_id] = other_user.id
          expect(Run.count).to eq(0)
          post "/api/v1/runs?token=#{access_token.token}", run_params, type: :json
          expect(Run.count).to eq(1)
          expect(
            response.body
          ).to eq(
            {
              id: Run.last.id,
              run_date: run_params[:run_date].to_time.iso8601,
              run_time: run_params[:run_time],
              distance: run_params[:distance],
              user: {
                id: other_user.id,
                name: other_user.name,
                email: other_user.email,
                role: other_user.role
              }
            }.to_json
          )
        end
      end
    end

  end

end
