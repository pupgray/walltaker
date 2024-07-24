class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :origin, optional: true, class_name: 'Profile'
  has_many :forks, dependent: :nullify, class_name: 'Profile', foreign_key: :origin_id
  has_many :users, foreign_key: :profile_id

  before_create do
    self.name ||= random_name
  end

  def number_of_users
    users.where(profile: [{ origin: self }, self]).count
  end

  private

  def random_name
    nouns = [Faker::Dessert.variety, Faker::Dessert.topping, Faker::Tea.variety, Faker::Creature::Animal.name, Faker::Creature::Bird.common_name, Faker::Creature::Bird.anatomy, Faker::TvShows::DrWho.character, Faker::TvShows::SiliconValley.invention, 'Pussy', 'Tits', 'Cock', 'Balls', 'Vulva', 'Testicles', 'Anus']
    adjectives = [Faker::Adjective.positive, Faker::Adjective.positive, Faker::Adjective.positive, Faker::Creature::Bird.silly_adjective, Faker::Creature::Bird.emotional_adjective, Faker::Creature::Bird.silly_adjective, Faker::Creature::Bird.emotional_adjective, Faker::Beer.brand, Faker::Verb.past_participle, Faker::Verb.past_participle, Faker::Verb.past_participle, Faker::Music.genre, 'Wet', 'Moist', 'Supple', 'Throbbing', 'Cum-Soaked', 'Big-Titty', 'Ass Sniffing']
    "#{adjectives.sample} #{nouns.sample}".titlecase
  end
end
