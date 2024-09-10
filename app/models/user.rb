require 'open-uri'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:github, :google_oauth2]
  has_many :posts
  has_one_attached :profile_picture #avatar(profile picture)

  def self.from_omniauth(access_token)
    user = User.where(email: access_token.info.email).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
        user = User.create(
          email: access_token.info.email,
          username: access_token.info.nickname,
          full_name: access_token.info.name, 
          omniauth_providers: access_token.provider,
          uid: access_token.uid,
          password: Devise.friendly_token[0,20]
        )
    end
    
    user.access_token = access_token.credentials.token
    user.refresh_token = access_token.credentials.refresh_token if access_token.credentials.refresh_token.present?
    user.expires_at = Time.at(access_token.credentials.expires_at) if access_token.credentials.expires_at.present?

    profile_picture_url = access_token.info.image
    unless user.profile_picture.attached?
      downloaded_image = URI.open(profile_picture_url)
      user.profile_picture.attach(io: downloaded_image, filename: "github_profile_picture.jpg")
    end

    user.save
    user
  end

  def destroy
    
  end


end
