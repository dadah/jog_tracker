module JogTracker
  module V1
    class Root < Grape::API
      mount JogTracker::V1::Runs
      mount JogTracker::V1::Users
      mount JogTracker::V1::Auth
    end
  end
end
