# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Source.create(identification_method: "CEO of Consumer Lending, focusing on growing lending and deposits.", identified_text: "We had a very strong commercial performance in [DATE_INTERVAL_2] with an increase in the number of customers, in lending and in deposits.", person_id: 1);
