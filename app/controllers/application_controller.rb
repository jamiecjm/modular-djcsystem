class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include LocalSubdomain

  def access_denied(exception)
    redirect_to root_path, alert: exception.message
  end

end
