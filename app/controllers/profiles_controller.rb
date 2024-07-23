class ProfilesController < ApplicationController
  before_action :authorize

  def create
    profile = current_user.profiles.build({ name: nil, content: '' })
    current_user.profile = profile
    current_user.save

    if profile.save && current_user.save
      redirect_to edit_user_path(current_user.username)
    else
      redirect_to edit_user_path(current_user.username), alert: 'something went wrong'
    end
  end

  def update
    form = ProfileRenameForm.from_params(params)

    if form && form.profile && current_user.profiles.include?(form.profile)
      if form.profile.update(name: form.name)
        redirect_to edit_user_path(current_user.username)
      else
        redirect_to edit_user_path(current_user.username), alert: 'something went wrong'
      end
    else
      redirect_to edit_user_path(current_user.username), alert: 'something went wrong'
    end
  end

  def destroy
    profile = Profile.find(params[:id])
    current_user.update(profile: nil)

    if profile && profile.destroy
      next_profile = current_user.profiles.order(id: :desc).first
      if next_profile
        current_user.profile = current_user.profiles.order(id: :desc).first
      else
        current_user.profile = nil
      end
      current_user.save
      redirect_to edit_user_path(current_user.username)
    else
      redirect_to edit_user_path(current_user.username), alert: 'something went wrong'
    end
  end

  def set_profile
    profile = ProfileSelectorForm.from_params(params).profile
    current_user.profile = profile

    if profile && current_user.save
      redirect_to edit_user_path(current_user.username)
    else
      redirect_to edit_user_path(current_user.username), alert: 'something went wrong'
    end
  end
end
