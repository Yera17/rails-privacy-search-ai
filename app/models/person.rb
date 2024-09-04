class Person < ApplicationRecord
  has_many :queries, dependent: :destroy
  has_many :sources, dependent: :destroy
end
