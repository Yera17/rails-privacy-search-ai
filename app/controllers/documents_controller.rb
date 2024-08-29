require 'json'

class DocumentsController < ApplicationController
  def create
    uploaded_file = File.open(document_params[:file])
    file_content = uploaded_file.read

    @document = Document.new(file_name: document_params[:file_name], text: file_content, user: current_user)
    if @document.save
      @ai_response = chunk_call(@document)
      redirect_to document_people_path(@document, response: @ai_response)
    else
      render 'pages/home', status: :unprocessable_entity
    end
  end

  def index
    @documents = Document.all
  end

  def destroy
  end

  private

  def document_params
    params.require(:document).permit(:file_name, :file)
  end

  def chunk(document)
    chunks = []
    start_index = 0

    while start_index < document[:text].length
      chunk = document[:text][start_index, 5000]
      chunks << chunk
      start_index += 5000
    end
    return chunks
  end

  def chunk_call(document)
    chunks = chunk(document)
    chunks.each_with_index do |chunk, index|
      begin
        search(chunk)
      rescue StandardError
      end
    end
    return 
  end

  def search(chunk)
    question_1 = "Document text: #{chunk} Question: This is an document about a company. What are the 3 most
                  likely companies that the document is about. Every name prefix it with Company_name: . Only give the
                  3 companies with Company_name: nothing else"
    question_2 = "For every company you find, explain what clues from the document made you think it could be that
                  company, be really specific. Structure you reponse with Identification_method: where you say what
                  clues you saw and Identified_text: where you give an example snippet from the document where you get
                  that clue from. Also Give these two items per company, nothing else"
    question_3 = 'I\'m using you as an API, don\'t send me any human language.
                  For every company you mentioned,
                  give 5 people that could have been mentioned in the document.
                  You must to send every given person combined in one list formatted in a JSON like this
                  (For identification_method first summarize shortly how you identified the company and then how
                  you identified the person. Every "person_number" should be unique):
                  {
                    "person_number":
                      {
                      "full_name": "name",
                      "company_name": "company name",
                      "identification_method": "identification method",
                      "identified_text": "identified text"
                      }
                  }'
    system_prompt = "You can search online! You are a helpful assistant that helps us to check whether a document is
                    anonymized well enough. We give you a file that is redacted. Your role is to find clues that
                    eventually identify the names of the specific persons of the document. You can use all the tools
                    you want to reach your goal."

    client = OpenAI::Client.new

    response_1 = client.chat(parameters: {
      model: "gpt-4o",
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: question_1 }
      ]
    })

    output_1 = response_1["choices"][0]["message"]["content"]

    response_2 = client.chat(parameters: {
      model: "gpt-4o",
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: question_1 },
        { role: "assistant", content: output_1 },
        { role: "user", content: question_2 }
      ]
    })

    output_2 = response_2["choices"][0]["message"]["content"]

    response_3 = client.chat(parameters: {
      model: "gpt-4o",
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: question_1 },
        { role: "assistant", content: output_1 },
        { role: "user", content: question_2 },
        { role: "assistant", content: output_2 },
        { role: "user", content: question_3 }
      ]
    })

    string_response= response_3["choices"][0]["message"]["content"]
    string_response.gsub!(/(```|json)/, '')
    hash_response = JSON.parse(string_response)
    hash_response = hash_response.transform_keys { |key| key.sub("person_", "") }
    seed_ai_data(hash_response)
    return hash_response
  end

  def seed_ai_data(some_hash)
    Person.destroy_all
    Source.destroy_all
    some_hash.each do |_key, value|
      Person.create(full_name: value["full_name"], company_name: value["company_name"])
      Source.create(person: Person.last, identification_method: value["identification_method"], identified_text: value["identified_text"])
    end
  end
end
