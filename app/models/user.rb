require 'open-uri'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:github, :google_oauth2, :vanadium]
  has_many :posts
  has_one_attached :profile_picture #avatar(profile picture)

  def self.from_omniauth(access_token, auth_hash=nil)

    email = access_token.info.email || (auth_hash[:info][:email])

    Rails.logger.info("email from vanadium: #{email}")


    user = User.where(email: email).first
    OmniAuth.config.logger = Rails.logger
    # Uncomment the section below if you want users to be created if they don't exist
    unless user
        user = User.create(
          email: email,
          username: access_token.info.nickname || auth_hash[:info][:name],
          full_name: access_token.info.name || auth_hash[:info][:name],
          omniauth_providers: access_token.provider || auth_hash[:provider],
          uid: access_token.uid || auth_hash[:uid], 
          password: Devise.friendly_token[0,20]
        )
    end
    
    Rails.logger.info("Access Token: #{access_token}")

    profile_picture_url = access_token.info.image

    if !user.profile_picture.attached? && profile_picture_url.present?
      downloaded_image = URI.open(profile_picture_url)
      user.profile_picture.attach(io: downloaded_image, filename: "github_profile_picture.jpg")
    end

    user.save
    user
  end


end
