class Person < ApplicationRecord
  has_many :queries, dependent: :destroy
  has_many :sources, dependent: :destroy

  # after_create :broadcast_person

  # private

  # def broadcast_person
  #   broadcast_append_to "document_#{document_id}_people",
  #                       partial: "people/people",
  #                       locals: { person: self }
  # end
end
