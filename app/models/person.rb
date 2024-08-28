class Person < ApplicationRecord
  has_many :queries, :sources, dependent: :destroy
end
