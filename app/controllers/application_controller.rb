class ApplicationController < ActionController::Base
  include Pagy::Backend

  delegate :get_tag_results, to: :e621_module
  delegate :get_possible_post_count, to: :e621_module
  delegate :get_search_base, to: :e621_module
  delegate :get_post, to: :e621_module

  helper_method :get_tag_results
  helper_method :get_possible_post_count
  helper_method :get_search_base
  helper_method :get_post

  before_action :broadcast_flash_message

  def e621_module
    @e621 ||= E621.new
  end

  def broadcast_flash_message
    return unless request.format.turbo_stream?
    return if response.status == 301 || response.status == 302
    return unless current_user

    flash.each do |type, msg|
      Turbo::StreamsChannel.broadcast_append_to("#{current_user.username}-flashes",
                                                target: 'flashes', partial: 'application/flash',
                                                locals: { msg:, type: })
    end
  end

  private

  # @param [Symbol<:regular, :nefarious, :visit>] level
  # @param [Symbol, String] id
  def track (level, id, **details)
    action = "#{controller_name}##{action_name}"

    event_name = "#{level}:#{id}"

    all_details = { _action: action }.merge details
    all_details = { _url: request.url } if level == :visit && request && request.url
    all_details = all_details.merge({ _link_id: @link.id, _link_owner_id: @link.user_id }) if @link
    all_details = all_details.merge({ _user_id: @user.id }) if @user
    all_details = all_details.merge({ _past_link_id: @past_link.id }) if @past_link

    ahoy.track event_name, all_details
  end

  def track_visit
    track :visit, request.path unless request.format == :json
  end

  def current_user
    @current_user ||= User.find(cookies.signed[:permanent_session_id]) if cookies.signed[:permanent_session_id]
    @current_user ||= User.find(session[:user_id]) if session[:user_id]

    @current_user
  end

  helper_method :current_user

  def notifications
    if current_user
      Notification.all.where(user: current_user).order(id: :desc).limit(5)
    else
      []
    end
  end

  helper_method :notifications

  def log_link_presence (link)
    if request.format == :json
      link.last_ping = Time.now.utc
      link.last_ping_user_agent = request.user_agent if request.user_agent
      link.last_ping_user_agent = @link.last_ping_user_agent + ' ' + request.headers['joihow'] if @link.last_ping_user_agent && request.headers['joihow']
      link.last_ping_user_agent = @link.last_ping_user_agent + ' ' + request.headers['User_Agent'] if @link.last_ping_user_agent && request.headers['User_Agent']
      link.last_ping_user_agent = @link.last_ping_user_agent + ' Wallpaper-Engine-Client/' + request.headers['Wallpaper-Engine-Client'] if @link.last_ping_user_agent && request.headers['Wallpaper-Engine-Client']
      link.save
    end
  end

  helper_method :log_link_presence

  def on_link_react (link)
    # Make notification for setter
    notification_text = "#{link.user.username} loved your post!" if link.response_type == 'horny'
    notification_text = "#{link.user.username} did not like your post." if link.response_type == 'disgust'
    notification_text = "#{link.user.username} came to your post!" if link.response_type == 'came'
    notification_text = "#{link.user.username} says thanks" if link.response_type == 'ok'
    notification_text = "#{notification_text} \"#{link.response_text}\"" unless link.response_type.nil? || link.response_text.empty?
    Notification.create user_id: link.set_by_id, notification_type: :post_response, text: notification_text, link: "/links/#{link.id}"

    # Log reaction in chat sidebar
    comment_text = "> loved it! #{ link.post_url }" if link.response_type == 'horny'
    comment_text = "> hated it. #{ link.post_url }" if link.response_type == 'disgust'
    comment_text = "> came to it! #{ link.post_url }" if link.response_type == 'came'
    comment_text = "> liked it #{ link.post_url }" if link.response_type == 'ok'
    Comment.create user_id: link.user.id, link_id: link.id, content: comment_text
    Comment.create user_id: link.user.id, link_id: link.id, content: link.response_text unless link.response_type.nil?

    # If a came reaction, log an orgasm
    Nuttracker::Orgasm.create rating: 3, is_ruined: false, user: link.user, caused_by: link.set_by if link.response_type == 'came'

    if link.response_type == 'came' && link.user.nut_pledge.present?
      link.user.nut_pledge.past_link = link.past_links.last
      link.user.nut_pledge.save
    end

    # If a disgust reaction, revert to old wallpaper
    if link.response_type == 'disgust'
      past_links = PastLink.where(link_id: link.id, post_url: link.post_url)
      past_links.destroy_all unless past_links.empty?

      last_past_link = PastLink.where(link_id: link.id).where.not(post_url: link.post_url).order('created_at').last

      link.post_url = last_past_link ? last_past_link.post_url : nil
      link.post_thumbnail_url = last_past_link ? last_past_link.post_thumbnail_url : nil
    end

    link
  end

  def surrender_controller
    return nil unless helpers.is_surrender_controller_session?
    begin
      Surrender.find(cookies.signed[:surrender_id])&.controller
    rescue
      nil
    end
  end

  # @param [User] user
  # @param [Surrender] surrender
  def log_in_as(user, surrender = nil)
    session[:user_id] = user.id
    cookies.signed[:permanent_session_id] = nil

    if surrender
      cookies.signed[:surrender_id] = surrender.id
      Notification.create user:, notification_type: :surrender_event, link: root_path, text: "#{surrender.controller.username} logged in as you."
      redirect_to root_path, notice: "#{surrender.controller.username} has logged in as #{ user.username }"
    else
      cookies.signed[:surrender_id] = nil
      redirect_to root_path
    end

  end

  def kick_bad_surrender_controllers
    if helpers.is_surrender_controller_session?
      begin
        surrender = Surrender.find(cookies.signed[:surrender_id])
        if !surrender || !surrender.active?
          session[:user_id] = nil
          cookies.signed[:surrender_id] = nil
          surrender.destroy if surrender
          return redirect_to new_session_url, alert: 'Account surrender for user is over.'
        end
      rescue
        session[:user_id] = nil
        cookies.signed[:surrender_id] = nil
        return redirect_to new_session_url, alert: 'Account surrender for user is over.'
      end
    end
  end

  def authorize_for_surrendered_accounts
    return redirect_to new_session_url, alert: 'Error 500, service/E621 down?' if current_visit&.banned_ip.present?

    return redirect_to new_session_url, alert: 'Not authorized' if current_user.nil?

    return kick_bad_surrender_controllers
  end

  def authorize
    result = authorize_for_surrendered_accounts
    return result if result

    result_two = disallow_surrendered_accounts
    return result_two if result_two

    if helpers.is_surrender_controller_session? && request.method == 'GET'
      begin
        surrender = Surrender.find(cookies.signed[:surrender_id])
        surrender.current_page = request.path
        surrender.save
      rescue
      end
    end

    true
  end

  def disallow_surrendered_accounts
    current_surrender = current_user&.current_surrender
    if cookies.signed[:surrender_id].nil? && current_surrender && current_surrender.active?
      return redirect_to current_surrender, alert: "#{current_surrender.user.username} attempted to use walltaker while their account is surrendered."
    end

    return kick_bad_surrender_controllers
  end

  def authorize_with_admin
    redirect_to '/', alert: 'Not authorized' unless current_user && current_user.admin
  end

  def authorize_with_admin_or_lizard
    redirect_to '/', alert: 'Not authorized' unless current_user

    is_lizard = %w[PornLizardWarren PornLizardKi PornLizardTaylor].include?(current_user.username)
    redirect_to '/', alert: 'Not authorized' unless current_user && (current_user.admin || is_lizard)
  end
end
