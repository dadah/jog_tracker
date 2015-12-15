module JogTracker
  module V1
    module Defaults
      extend ActiveSupport::Concern

      included do
        version 'v1'
        format :json

        params do
          optional :token, type: String
        end

        helpers do
          def current_user
            return false unless params[:token].present?
            @current_user ||= User.joins(:access_tokens).
              where(access_tokens: { token: params[:token] }).
              where("access_tokens.expires_in > ?", DateTime.now).first
          end

          def authorize role='user'
            error!("Login required", 401) unless current_user
            error!("You are not allowed to access this resource", 403) if User.roles[current_user.role] < User.roles[role]
          end
        end
      end
    end
  end
end
