class Document < ApplicationRecord
  belongs_to :user
  has_many :people, dependent: :destroy
  validates :file_name, presence: true
end
