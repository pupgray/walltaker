# frozen_string_literal: true

class ProfileRenameForm
  include ActiveModel::API

  attr_accessor :profile_id, :name

  def profile
    Profile.find(profile_id)
  end

  def self.from_user(user)
    return new(profile_id: user.profile.id, name: user.profile.name) if user.profile
    new(profile_id: nil, name: '') unless user.profile
  end

  def self.from_params(params)
    new params.require(:profile_rename_form).permit(:profile_id, :name)
  end
end
