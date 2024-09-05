class Person < ApplicationRecord
  has_many :sources, dependent: :destroy
end
