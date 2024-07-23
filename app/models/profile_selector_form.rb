# frozen_string_literal: true

class ProfileSelectorForm
  include ActiveModel::API

  attr_accessor :profile_id

  def profile
    Profile.find(profile_id)
  end

  def self.from_user(user)
    return new(profile_id: user.profile.id) if user.profile
    new(profile_id: nil) unless user.profile
  end

  def self.from_params(params)
    new params.require(:profile_selector_form).permit(:profile_id)
  end
end
