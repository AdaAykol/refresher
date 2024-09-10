# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end


  def destroy

    if current_user.access_token.present? && current_user.omniauth_providers == "google_oauth2"
      revoke_google_token(current_user.access_token)
    end

    current_user.update(access_token: nil, refresh_token: nil, expires_at: nil)
    super
  end

  def revoke_google_token(token)
    uri = URI("https://accounts.google.com/o/oauth2/revoke?token=#{token}")
    response = Net::HTTP.post_form(uri, {})
    if response.is_a?(Net::HTTPSuccess)
      Rails.logger.info "Google OAuth token successfully revoked."
    else
      Rails.logger.error "Failed to revoke Google OAuth token: #{response.body}"
    end
  end
  

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
