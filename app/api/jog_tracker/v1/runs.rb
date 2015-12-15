module JogTracker
  module V1
    class Runs < Grape::API
      include JogTracker::V1::Defaults

      resources :runs do
        helpers do
          def get_user
            if params[:user_id].present?
              error!("You are not allowed to create runs for user #{params[:user_id]}", 403) if current_user.user? && params[:user_id].to_i != current_user.id
              user = User.find_by id: params[:user_id]
              error!("User not found", 404) unless user.present?
              error!("You are not allowed to change ownership to user #{params[:user_id]}", 403) unless current_user.admin? || User.roles[user.role] < User.roles[current_user.role] || params[:user_id].to_i == current_user.id
              user
            else
              current_user
            end
          end
        end

        params do
          optional :starts_at, type: Date
          optional :ends_at, type: Date
        end

        get do
          authorize
          if current_user.user?
            error!("You are not allowed to access this resource", 403) if params[:user_id].present? && params[:user_id].to_i != current_user.id
            runs = Run.where(user_id: current_user.id)
          else
            runs = params[:user_id].present? ? Run.where("user_id = ?", params[:user_id]) : Run
            if current_user.user_manager?
              runs = runs.joins(:user).where("users.role < ? OR runs.user_id = ?", User.roles[current_user.role], current_user.id)
            end
          end
          runs = runs.where("run_date >= ?", params[:starts_at]) if params[:starts_at].present?
          runs = runs.where("run_date <= ?", params[:ends_at]) if params[:ends_at].present?
          present runs.includes(:user).all, with: JogTracker::V1::Entities::Run
        end

        get ':run_id' do
          authorize
          run = Run.includes(:user).find_by id: params[:run_id]
          error!("Resource not found", 404) unless run.present?
          error!("You are not allowed to update this run", 403) unless current_user.admin? || run.user_id == current_user.id || User.roles[run.user.role] < User.roles[current_user.role]
          present run, with: JogTracker::V1::Entities::Run
        end

        delete ':run_id' do
          authorize
          run = Run.includes(:user).find_by id: params[:run_id]
          error!("Resource not found", 404) unless run.present?
          error!("You are not allowed to update this run", 403) unless current_user.admin? || run.user_id == current_user.id || User.roles[run.user.role] < User.roles[current_user.role]
          run.destroy
          body = false
        end

        params do
          requires :run_date, type: DateTime
          requires :run_time, type: Integer
          requires :distance, type: Integer
          optional :user_id, type: Integer
        end

        put ':run_id' do
          authorize
          run = Run.includes(:user).find_by id: params[:run_id]
          error!("Resource not found", 404) unless run.present?
          error!("You are not allowed to update this run", 403) unless current_user.admin? || run.user_id == current_user.id || User.roles[run.user.role] < User.roles[current_user.role]
          run.update_attributes user: get_user,
            distance: params[:distance],
            run_date: params[:run_date],
            run_time: params[:run_time]
          present run, with: JogTracker::V1::Entities::Run
        end

        params do
          requires :run_date, type: DateTime
          requires :run_time, type: Integer
          requires :distance, type: Integer
          optional :user_id, type: Integer
        end

        post do
          authorize
          run = Run.new user: get_user,
            distance: params[:distance],
            run_date: params[:run_date],
            run_time: params[:run_time]
          run.save!
          present run, with: JogTracker::V1::Entities::Run
        end

      end

    end
  end
end
