class Key < ApplicationRecord
  validates :purpose, presence: true, uniqueness: true
  validates :public, presence: true
  validates :private, presence: true
end
