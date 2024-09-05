# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.destroy_all
User.create(first_name: 'Yerkanat',
            last_name: 'Salaly',
            email: 'erko.salaly@gmail.com',
            password: '12345678',
            password_confirmation: '12345678')

User.create(first_name: 'Vidya',
            last_name: 'Venkataraju',
            email: 'vidya1141@gmail.com',
            password: '12345678',
            password_confirmation: '12345678')

User.create(first_name: 'Syilagan',
            last_name: 'Akberdy',
            email: 'syilagan@icloud.com',
            password: '12345678',
            password_confirmation: '12345678')

User.create(first_name: 'Jelle',
            last_name: 'Sijm',
            email: 'jellesijm1@gmail.com',
            password: '12345678',
            password_confirmation: '12345678')

document = Document.create(file_name: 'test', text: "", user_id: this_user.id)

some_hash = { "Steven van Rijswijk" => "ING Group",
              "Tanate Phutrakul" => "ING Group",
              "Andrew Bester" => "ING Group",
              "Tom de Swaan" => "ABN AMRO",
              "Robert Swaak" => "ABN AMRO",
              "Christian Bornfeld" => "ABN AMRO",
              "Bart Leurs" => "Rabobank",
              "Bas Brouwers" => "Rabobank",
              "Wiebe Draijer" => "Rabobank" }

steven_i_m = "The company is identified based on these clues: The document discusses financial performance, targets, and strategies, which aligns with the typical content of a bank's results call. ING Group is a major banking institution known for such detailed financial discussions. The emphasis on digital banking, customer growth, and financial performance is consistent with ING's known focus on digital banking and customer engagement."
steven_i_t = "The person is identified based on these clues: Steven van Rijswijk is identified as the CEO of ING Group, which is a key position that would be involved in presenting financial results and strategies. His role as CEO and member of the Executive Board and Management Board Banking makes him a likely candidate to be mentioned in such a document."

some_hash.each do |k, v|
  person = Person.create(full_name: k, company_name: v, document_id: document.id)
  Source.create(person: person,
                identification_method: steven_i_m,
                identified_text: steven_i_t)
end
