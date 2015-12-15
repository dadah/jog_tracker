module JogTracker
  module V1
    class Auth < Grape::API
      include JogTracker::V1::Defaults

      resources :auth do
        params do
          requires :email, allow_blank: false, regexp: Settings.valid_email_regex
          requires :password, type: String
        end

        post do
          user = User.find_by(email: params[:email]).try(:authenticate, params[:password])
          if user
            user.reset_tokens
            access_token = AccessToken.new user: user
            access_token.save!
            present access_token, with: JogTracker::V1::Entities::AccessToken
          else
            status 401
          end
        end
      end

    end
  end
end
