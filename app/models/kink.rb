class Kink < ApplicationRecord
  include PgSearch::Model
  validates_uniqueness_of :name
  validates_length_of :name, maximum: 30, minimum: 1
  validates_associated :kink_havers, message: 'must only have one of each kink.'

  normalizes :name, with: -> name { name.gsub(/[^\w\d_\-\(\)\/\s]/, '').strip.squish.downcase.gsub(/\s/, '_') }

  has_many :kink_havers
  has_many :users, through: :kink_havers
  has_many :links, through: :users

  pg_search_scope :search_name, against: :name, using: { tsearch: { dictionary: 'english', prefix: true, any_word: true }, trigram: { threshold: 0.2 } }

  def test_on_e621
    begin
      result = ApplicationController.new.get_tag_results(name, nil, nil, nil, 1);
    rescue
      result = nil
    end

    if result && result.length > 0
      self.works_on_e621 = true
    else
      self.works_on_e621 = false
    end

    save
  end

  # @param [User] by
  def had_by (by)
    self.kink_havers.find_by(user_id: by.id)
  end

  # @param [User] by
  def is_starred? (by)
    kink_haver = had_by(by)
    kink_haver&.is_starred? || false
  end

  def to_s
    name
  end
end
