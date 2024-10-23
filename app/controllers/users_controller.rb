# frozen_string_literal: true

class UsersController < ApplicationController
  # Strongly consider Devise (generally not a good idea to roll your own auth)
  def create
    # consider this line in to the #users_params method, then use before_action above (create)
    user_params = params.require(:user).permit(:name, :email, :password, :password_confirmation)

    password = user_params[:password].to_s.strip
    password_confirmation = user_params[:password_confirmation].to_s.strip

    # Validate password, extracted in to PasswordValidator
    # - We should ensure password strength meets some minimum standard (e.g. minimum size, etc.])
    errors = {}
    errors[:password] = ["can't be blank"] if password.blank?
    errors[:password_confirmation] = ["can't be blank"] if password_confirmation.blank?

    # take a look at the guard pattern, as opposed to a nested if
    if errors.present?
      render_json(422, user: errors)
    else
      # This if statement should be extracted out of here, this is effectively an error
      if password != password_confirmation
        render_json(422, user: { password_confirmation: ["doesn't match password"] })
      else
        password_digest = Digest::SHA256.hexdigest(password)

        user = User.new(
          name: user_params[:name],
          email: user_params[:email],
          token: SecureRandom.uuid,
          password_digest: password_digest
        )

        if user.save
          render_json(201, user: user.as_json(only: [:id, :name, :token]))
        else
          render_json(422, user: user.errors.as_json)
        end
      end
    end
  end

  def show
    # extract this out into a before_action only: %i[show destroy], rails convention
    # A note about why for rails conventions: sticking to common conventions helps
    # newer (to the company) engineers ramp up much faster, because they've seen these patterns elsewhere
    perform_if_authenticated
  end

  def destroy
    perform_if_authenticated do
      current_user.destroy
    end
  end

  private

    def perform_if_authenticated(&block)
      authenticate_user do
        block.call if block

        render_json(200, user: { email: current_user.email })
      end
    end
end
