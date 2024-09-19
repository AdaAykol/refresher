class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [:github]
  def github
      access_token = request.env["omniauth.auth"]

      Rails.logger.debug "omniauth response: #{access_token.inspect}"
      
      Rails.logger.debug "omniauth response: #{access_token.info.email.inspect}"

      Rails.logger.debug "Profile picture URL: #{access_token.info.image}"

      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Github'
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.github_data'] = request.env['omniauth.auth'].except('extra') # Removing extra as it can overflow some session stores
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
  end


  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    access_token = request.env["omniauth.auth"]
    Rails.logger.debug "omniauth response: #{access_token.inspect}"

    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect @user, event: :authentication
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except('extra') # Removing extra as it can overflow some session stores
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def vanadium
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user
    else
      session['devise.vanadium_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end