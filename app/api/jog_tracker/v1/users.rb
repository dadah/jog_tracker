module JogTracker
  module V1
    class Users < Grape::API
      include JogTracker::V1::Defaults

      resources :users do

        helpers do
          def get_user id
            user = User.find_by id: params[:user_id]
            error!("Not Found", 404) unless user.present?
            error!("You are not allowed to access this resource", 403) unless current_user.admin? || User.roles[current_user.role] > User.roles[user.role] || user.id == current_user.id
            user
          end
        end

        get 'me' do
          authorize
          present current_user, with: JogTracker::V1::Entities::User
        end

        params do
          requires :name, type: String
          requires :email, allow_blank: false, regexp: Settings.valid_email_regex
          requires :password, type: String
        end

        post do
          user = User.new params.extract!(:name, :email, :password, :role)
          user.save!
          present user, with: JogTracker::V1::Entities::User
        end

        get do
          authorize "user_manager"
          present User.where("role <= ?", User.roles[current_user.role]).all, with: JogTracker::V1::Entities::User
        end

        get ':user_id' do
          authorize
          user = get_user params[:user_id]
          present user, with: JogTracker::V1::Entities::User
        end

        params do
          requires :name, type: String
          requires :email, allow_blank: false, regexp: Settings.valid_email_regex
          requires :password, type: String
          optional :role, type: String
        end

        put ':user_id' do
          authorize
          user = get_user params[:user_id]
          error!("You are not allowed to upgrade role", 403) if params[:role].present? && params[:role] != user.role && !current_user.admin? && User.roles[current_user.role] <= User.roles[user.role]
          user.update_attributes params.extract!(:name, :email, :password, :role)
          present user, with: JogTracker::V1::Entities::User
        end

        delete ':user_id' do
          authorize
          user = get_user params[:user_id]
          user.destroy
          body false
        end

        resources ':user_id' do
          resources 'runs' do
            get do
              redirect "/api/v1/runs?user_id=#{params[:user_id]}&token=#{params[:token]}"
            end
            get ':run_id' do
              redirect "/api/v1/runs/#{params[:run_id]}?user_id=#{params[:user_id]}&token=#{params[:token]}"
            end
          end
        end
      end

    end
  end
end
