module JogTracker
  module V1
    module Entities

      class AccessToken < Grape::Entity
        expose :token
        expose :expires_in
      end

      class User < Grape::Entity
        expose :id
        expose :name
        expose :email
        expose :role
      end

      class Run < Grape::Entity
        format_with(:iso_timestamp) { |dt| dt.utc.iso8601 }
        expose :id
        with_options(format_with: :iso_timestamp) do
          expose :run_date
        end
        expose :run_time
        expose :distance
        expose :user, using: User
      end

    end
  end
end
