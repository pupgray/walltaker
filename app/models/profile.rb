class Profile < ApplicationRecord
  belongs_to :user

  before_create do
    self.name ||= random_name
  end

  private

  def random_name
    nouns = [Faker::Dessert.variety, Faker::Dessert.topping, Faker::Tea.variety, Faker::Creature::Animal.name, Faker::Creature::Bird.common_name, Faker::Creature::Bird.anatomy, 'Pussy', 'Tits', 'Cock', 'Balls', 'Vulva', 'Testicles']
    adjectives = [Faker::Adjective.positive, Faker::Creature::Bird.silly_adjective, Faker::Creature::Bird.emotional_adjective, Faker::Beer.brand, Faker::Verb.past_participle, 'Wet', 'Moist', 'Supple', 'Throbbing', 'Cum-Soaked', 'Big-Titty']
    "#{adjectives.sample} #{nouns.sample}".titlecase
  end
end
