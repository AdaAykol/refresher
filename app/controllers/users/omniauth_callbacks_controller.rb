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
    Rails.logger.debug "OmniAuth Auth Data: #{access_token.inspect}"
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

    auth = request.env['omniauth.auth']
    Rails.logger.info("Full OmniAuth Auth Hash: #{auth.to_json}")
  
    access_token = auth.credentials.token
  
    Rails.logger.info("Access Token: #{access_token}")

    response = RestClient.get('http://vanadium.localdev.me:3000/oauth/userinfo', {
      Authorization: "Bearer #{access_token}"
    })
    
    # Parse the JSON response
    user_info = JSON.parse(response.body)
    Rails.logger.info("User Info Response: #{user_info}")

    auth_hash = {
      provider: 'vanadium',
      uid: user_info["sub"],
      info: {
        email: user_info["email"],
        name: user_info["variable_name"]
      }
    }

    Rails.logger.info("receiving email: #{auth_hash[:info][:email]}")



    Rails.logger.debug "omniauth response: #{access_token.inspect}"
    @user = User.from_omniauth(request.env['omniauth.auth'], auth_hash)


    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Vanadium'
      sign_in_and_redirect @user
    else
      session['devise.vanadium_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url , alert: @user.errors.full_messages.join("\n")
    end
  end

end