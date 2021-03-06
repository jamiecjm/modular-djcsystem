ActiveAdmin::Dependency.devise! ActiveAdmin::Dependency::Requirements::DEVISE

require 'devise'

module ActiveAdmin
  module Devise

    def self.config
      {
        path: ActiveAdmin.application.default_namespace || "/",
        controllers: ActiveAdmin::Devise.controllers,
        path_names: { sign_in: 'login', sign_out: "logout" },
        sign_out_via: [*::Devise.sign_out_via, ActiveAdmin.application.logout_link_method].uniq
      }
    end

    def self.controllers
      {
        sessions: "active_admin/devise/sessions",
        passwords: "active_admin/devise/passwords",
        unlocks: "active_admin/devise/unlocks",
        registrations: "active_admin/devise/registrations",
        confirmations: "active_admin/devise/confirmations"
      }
    end

    module Controller
      extend ::ActiveSupport::Concern
      included do
        layout 'active_admin_logged_out'
        helper ::ActiveAdmin::ViewHelpers
      end

      # Redirect to the default namespace on logout
      def root_path
        namespace = ActiveAdmin.application.default_namespace.presence
        root_path_method = [namespace, :root_path].compact.join('_')

        path = if Helpers::Routes.respond_to? root_path_method
                 Helpers::Routes.send root_path_method
               else
                 # Guess a root_path when url_helpers not helpful
                 "/#{namespace}"
               end

        # NOTE: `relative_url_root` is deprecated by Rails.
        #       Remove prefix here if it is removed completely.
        prefix = Rails.configuration.action_controller[:relative_url_root] || ''
        prefix + path
      end
    end

    class SessionsController < ::Devise::SessionsController
      include ::ActiveAdmin::Devise::Controller
    end

    class PasswordsController < ::Devise::PasswordsController
      include ::ActiveAdmin::Devise::Controller
    end

    class UnlocksController < ::Devise::UnlocksController
      include ::ActiveAdmin::Devise::Controller
    end

    class RegistrationsController < ::Devise::RegistrationsController
      include ::ActiveAdmin::Devise::Controller
    end

    class ConfirmationsController < ::Devise::ConfirmationsController
      include ::ActiveAdmin::Devise::Controller

      def show
        self.resource = resource_class.confirm_by_token(params[:confirmation_token])
        yield resource if block_given?
        if resource.errors.empty?
          set_flash_message!(:notice, :confirmed)
          if resource.locked_at != nil
            UserMailer.approve_registration(resource, current_website).deliver
          end
          respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
        else
          respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
        end
      end
    end

    def self.controllers_for_filters
      [SessionsController, PasswordsController, UnlocksController,
        RegistrationsController, ConfirmationsController
      ]
    end

  end
end