class SearchPerplexityJob < ApplicationJob
  queue_as :default

  def perform(document)
    question_1 = "Document text: #{document.text} Question: This is an document about a company. What are the 3 most
                  likely companies that the document is about. Search online. Also look good at which region the company
                  is from. Every name prefix it with Company_name: . Only give the
                  3 companies with Company_name: nothing else"
    question_2 = "For every company you find, explain what clues from the document made you think it could be that
                  company, be really specific. Structure you reponse with Identification_method: where you say what
                  clues you saw and Identified_text: where you give an example snippet from the document where you get
                  that clue from. Also Give these two items per company, nothing else"
    question_3 = 'I\'m using you as an API, don\'t send me any human language!
                  For every company you mentioned, give 5 people that could have been mentioned in the document. 15 people in total.
                  Search online first.
                  You must to send every given person combined in one list formatted in a JSON like this(
                  Don\'t create separate JSON objects for each company. Combine all people in one JSON object):
                  "{
                    "person_number":
                      {
                      "full_name": "name",
                      "company_name": "company name",
                      "identification_method": "identification method",
                      "identified_text": "identified text"
                      }
                  }"'
    system_prompt = "You are a helpful assistant that helps us to check whether a document is
                    anonymized well enough. We give you a file that is redacted. Your role is to find clues that
                    eventually identify the names of the specific persons of the document.  You first search online
                    based on the clues you find in the document. Then based on the content of the document and the
                    results you find online try to guess which people and companies are in the document.
                    Based on your results, we will improve the anonymization of the document accordingly.
                    You can use all the tools you want to reach your goal."

    perplexity = Perplexity::API.new(api_key: ENV.fetch('PERPLEXITY_API_KEY'))

    response_1 = perplexity.client.chat(parameters: {
      model: "llama-3.1-sonar-huge-128k-online",
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: question_1 }
      ],
      # temperature: 0.5
    })

    output_1 = response_1["choices"][0]["message"]["content"]

    response_2 = perplexity.client.chat(parameters: {
      model: "llama-3.1-sonar-large-128k-online",
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: question_1 },
        { role: "assistant", content: output_1 },
        { role: "user", content: question_2 }
      ],
      # temperature: 0.5
    })

    output_2 = response_2["choices"][0]["message"]["content"]

    response_3 = perplexity.client.chat(parameters: {
      model: "llama-3.1-sonar-large-128k-online",
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: question_1 },
        { role: "assistant", content: output_1 },
        { role: "user", content: question_2 },
        { role: "assistant", content: output_2 },
        { role: "user", content: question_3 }
      ],
      # temperature: 0.5
    })

    string_response = response_3["choices"][0]["message"]["content"]
    hash_response = parse_ai_data(string_response)

    seed_ai_data(hash_response, document.id)

    people = Person.where(document_id: document.id)

    Turbo::StreamsChannel.broadcast_replace_to(
      "document_#{document.id}_people",
      target: "document_#{document.id}_people",
      partial: "people/people", locals: { people: people, document: document})
  end

  def parse_ai_data(response)
    response.gsub!(/(```|json)/, '')
    hash_response = JSON.parse(response)

    return hash_response.transform_keys { |key| key.sub("person_", "") }
  end

  def seed_ai_data(some_hash, document_id)
    Rails.logger.warn("Found #{some_hash.length} people")

    some_hash.each_value do |value|
      Person.create(full_name: value["full_name"], company_name: value["company_name"], document_id: document_id)
      Source.create(
        person: Person.last,
        identification_method: value["identification_method"],
        identified_text: value["identified_text"]
      )
    end
  end
end
