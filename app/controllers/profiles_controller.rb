class ProfilesController < ApplicationController
  before_action :authorize
  before_action :set_profile_property, only: %i[show show_preview]

  def index
    @user = User.find(params[:id]) if params[:id]
    @pagy, @profiles = pagy(Profile.where(public: true, user_id: params[:id]).includes(:users), items: 5) if params[:id]
    @pagy, @profiles = pagy(Profile.where(public: true).includes(:users), items: 5) unless params[:id]
  end

  def show
  end

  def show_preview
    base_user = User.find_by_username('evil')
    @user = User.build({
                         **base_user.attributes,
                         email: Faker::Internet.email,
                         username: "#{Faker::Adjective.positive.titlecase}#{Faker::Creature::Bird.anatomy.titlecase}",
                         profile: @profile,
                         advanced: true
                       })
    @has_friendship = false
    @links = Link.limit(2)
    @any_links_online = @links.is_online.count.positive?
    @most_recent_pinged_link = @links.order(last_ping: :desc).take(1) if @links.count.positive?
    @past_links = PastLink.take(5)
    @is_current_user = true

    render 'users/show'
  end

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
    if params['profile_rename_form'].present?
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
    elsif params['profile_adder_form'].present?
      form = ProfileAdderForm.from_params(params)

      if form && form.profile && form.profile.public
        copy = current_user.profiles.create(name: "#{form.profile.name} #{form.profile.updated_at.to_formatted_s(:short)}", content: form.profile.content, origin: form.profile)

        if copy
          current_user.profile = copy
          if current_user.save
            return redirect_to user_path(current_user.username)
          end
        end
      end

      redirect_to preview_profile_path(form.profile), alert: 'something went wrong'
    else
      profile = Profile.find(params[:id])
      if current_user.profiles.include?(profile)
        if profile.update(params.require(:profile).permit(:public))
          return render turbo_stream: turbo_stream.update(:sharing_form, partial: 'users/sharing_form', locals: { user: current_user })
        end
      end
      redirect_to preview_profile_path(profile), alert: 'something went wrong'
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

  private

  def set_profile_property
    @profile = Profile.find(params[:id])
    redirect_to root_path, alert: 'Not authorized' unless @profile.public
  end
end
