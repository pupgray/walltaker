# frozen_string_literal: true

class NewsEntry
  include ActiveModel::API
  include ActiveModel::Serializers::JSON

  attr_accessor :image_url, :message, :lizard_image_url, :type, :transition_message

  def initialize(**args)
    args[:lizard_image_url] ||= 'mascot/news/TaylorDeskOpen.png'
    super(**args)
  end

  # @param [PastLink] past_link
  def self.from_past_link(past_link)
    if past_link.user_id == past_link.set_by_id
      return NewsEntry.new(
        image_url: past_link.post_url,
        message: TaylorSpeech.new(tags: past_link.tags, tone: :neutral, setter: past_link.user.username, settee: past_link.user.username).to_s
      )
    else
      return NewsEntry.new(
        image_url: past_link.post_url,
        message: TaylorSpeech.new(tags: past_link.tags, tone: :neutral, setter: past_link.set_by&.username || 'anon', settee: past_link.user.username).to_s
      )
    end
  end

  def self.from_scoop(scoop)
    NewsEntry.new(
      image_url: nil,
      type: 'scoop',
      message: scoop.details + " - #{scoop.user.username}",
      lizard_image_url: scoop.interview_image_url,
      transition_message: "Breaking news from #{scoop.user.username}!"
    )
  end

  def attributes
    { 'image_url' => nil, 'message' => '', 'lizard_image_url' => 'mascot/news/TaylorDeskOpen.png', 'type' => 'post', 'transition_message' => nil }
  end
end

class TaylorSpeech
  def initialize(tags: '', tone: :neutral, setter:, settee:)
    @tags = tags.split(' ')
    @fun_tags = @tags.intersection(%w[impregnation clothing_lift shirt_lift male/female covering saggy_balls partially_clothed screaming submissive struggling bound butt_grab hole_in_wall thrusting through_wall erect_nipples presenting_breasts impregnation_request saliva excessive_cum presenting_hindquarters cum_in_pussy cum_in_ass cum_pool cum_on_clothing cum_on_face penis_milking public_sex free_use pussy butt anus penis presenting_pussy presenting_anus cum breasts big_breasts big_balls balls feral male female canine equine feline paws feet hypnosis vore big_muscles muscular precum looking_at_viewer rear_view fox seductive bedroom_eyes huge_breasts underboob interspecies big_butt femboy clothed voyeur masturbation penile_masturbation mating_press outside_sex kissing penis_in_ass penis_in_pussy raised_tail scut_tail deer being_watched ejaculation humiliation tail fur knot makeup musk musky_cock nipples spread_legs throbbing veiny_penis canine_penis equine_penis horse anthro cum_request glory_hole half_erect jockstrap kneeling fellatio first_person_view floppy_ears male/male female/female penetrating_pov penis_in_mouth saliva_on_penis holding_penis leaking underwear flaccid flared_penis fangs belly_nipples eyes_closed bulge drooling bovid cow sheep pull_out loimu_(character)])

    if @tags.intersect?(%w[impregnation impregnation_request excessive_cum presenting_pussy cum_in_pussy cum_pool cum_on_clothing cum_on_face penis_milking public_sex free_use])
      @tone = :horny
    elsif @tags.include?('jerma985')
      @tone = :jerma985
    elsif @tags.intersect?(%w[clothed rating:s meme])
      @tone = :bored
    else
      @tone = tone
    end
    @setter = setter
    @settee = settee
  end

  def exclamation
    return ["Wow!", "Huff.", "Kinky!", "Oh~", "Oh!~", "Fuck yes finally.", "Fucking finally.", "Finally.", "Oh fuck.", "Oh shit."].sample if @tone == :horny

    return ["Eh.", "And yep.", "Next thing...", "Uhh...", "Hmm.", "Mmhmm.", nil, nil, nil, nil, nil, nil].sample if @tone == :bored

    ["Oh wow.", "Oh my.", "Goodness!", "Heh.", "Ay!", nil, nil, nil, nil, nil, nil].sample
  end

  def transition
    return ["I also seeEeEe,", "Oh I love this,", "Oh really?~", "Heheheh,", 'Oh!'].sample if @tone == :horny

    ["In other news,", "Otherwise,", "Also,", "As well,", "I also see,", "I also heard that we have", "Just in!", "Next,", "Some #{Faker::Adjective.positive} news,"].sample
  end

  def introduction
    return ["something good!", "something hot!", "huff.", "someone with good taste.", @fun_tags.sample + "!", "GOOD PORN.", "Goon material."].sample if @tone == :horny

    return ["we have a new change!", "a new #{Faker::Adjective.positive} wallpaper.", "something different on a local lizard's phone.", "a change of pace.", "what you'd expect.", nil, nil, nil].sample if @tone == :neutral

    return ['some potential spam.', 'a... unique choice of wallpaper.', "a... unique #{@tags.sample} background.", "a #{Faker::Adjective.negative} choice.", "a #{@tags.sample} e621 post got it first view.", "slow news day!", "some #{@tags.intersection(%w[clothed rating:s meme]).sample} bullshit.", nil, nil, nil, nil, nil, nil].sample if @tone == :bored
  end

  def news
    base = ['wallpaper', 'background', 'post'].sample
    noun = ["some fresh #{@fun_tags.sample} smut", "some hot #{@fun_tags.sample} action", "a really hot #{@fun_tags.sample} #{base}", "a sexy #{@fun_tags.sample} #{base}", "full-on #{Faker::Adjective.positive} #{@fun_tags.sample} debauchery.", "something #{@fun_tags.sample}-y"].sample if @tone == :horny
    noun = ["a new #{@fun_tags.sample} #{base}", "an all-new #{@fun_tags.sample} focused #{base}", "a #{Faker::Adjective.positive} look", "a #{@fun_tags.sample}-y look", "a #{Faker::Adjective.positive} #{@fun_tags.sample} post", "something #{@fun_tags.sample}-y", "something very deserving of the #{@fun_tags.sample} tag", "a #{Faker::Adjective.positive} #{@fun_tags.sample}"].sample if @tone == :neutral
    noun = ["a #{base}", "this #{base}", "some random #{base}", "a #{@tags.sample} #{base}", "this #{Faker::Adjective.negative} #{base}", "something #{@tags.sample}-y"].sample if @tone == :bored

    verb = ["settled on #{noun}", "chose #{noun}, out of everything on e621", "cursed us with #{noun}", "gave up and chose #{noun}", "collapsed on their keyboard and accidentally chose #{noun}", "was feeling #{Faker::Adjective.negative} and picked #{noun}", "couldn't see the thumbnail because Gray still hasn't made it possible to preview a wallpaper in the porn search, resulting in #{noun}"].sample if @tone == :bored
    verb = ["chose #{noun}", "selected #{noun}", "sent over #{noun}", "picked #{noun}", "loved #{noun} with bonus #{@fun_tags.sample} theme", "decided on #{noun}", "landed on #{noun}", "chose #{noun}, out of everything on e621"].sample if @tone != :bored
    phrase = ["#{@setter} #{verb} for #{@settee}.", "#{@setter} went and #{verb} on behalf of #{@settee}.", "#{@setter} #{verb} just for #{@settee}.", "#{@setter} had some #{@fun_tags.sample}-inspiration and #{verb} for #{@settee}.", "The always #{Faker::Adjective.positive} #{@setter} #{verb} for #{@settee}.", "#{@setter} #{verb} for the always #{Faker::Adjective.positive} #{@settee}.", "#{@setter} and #{@settee} seem to have #{verb}.", "The #{@fun_tags.sample}-loving duo of #{@setter} and #{@settee} have #{verb}."].sample

    phrase.humanize
  end

  def to_s
    return ['-2', 'we are the rats, we are the rats, we stalk at night we prey at night we are the rats.', "I don't look anything like the yellow m&m", "It's a 'gweh' game, I like it", "No. I'm not gonna put on Dr. Phil.", "I call this one the goddamn orangutan", "I've never said yeet before in my whole life.", "I'm seriously gonna go sit down on the toilet and piss up into my face.", "Smarties are great up your urethra.", "Hey, guy! Yaw-hey, hey! You know what I say? Always split eights! ALWAYS SPLIT EIGHTS! See, that's what I say!", "The Greedy Grinner... never has insurance."].sample if @tone == :jerma985

    [
      [exclamation&.humanize, transition, introduction, news].join(' '),
      [transition&.humanize, introduction, news, exclamation].join(' '),
      [introduction&.humanize, exclamation, news].join(' '),
      [news, exclamation&.humanize].join(' '),
    ].sample
  end
end
