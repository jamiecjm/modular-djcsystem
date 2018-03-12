require 'active_admin/base_controller'
ActiveAdmin::BaseController.class_eval do
  unless Rails.application.config.consider_all_requests_local
    rescue_from ActionController::RoutingError, with: -> { redirect_to_root  }
    rescue_from ActionController::UnknownController, with: -> { redirect_to_root  }
    rescue_from ActiveRecord::RecordNotFound,        with: -> { redirect_to_root  }
  end
  def redirect_to_root
    redirect_to root_path
  end
end