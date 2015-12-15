module JogTracker
  class API < Grape::API
    rescue_from Grape::Exceptions::ValidationErrors do |e|
      handler = lambda {|arg| error_response(arg)}
      exec_handler(e, &handler)
    end
    rescue_from :all
    prefix 'api'
    error_formatter :json, JogTracker::ErrorFormatter
    mount JogTracker::V1::Root
  end
end
