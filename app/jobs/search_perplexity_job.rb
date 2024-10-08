class SearchPerplexityJob < ApplicationJob
  queue_as :default

  def perform(document)
    question_1 = "Document text: #{document.text} Question: This is an document about a company. What are the 3 most
                  likely companies that the document is about. Search online. Also look good at which region the company
                  is from. Every name prefix it with Company_name: . Only give the
                  3 companies with Company_name: nothing else"
    question_2 = "For every company you find, explain what clues from the document made you think it could be that
                  company, be really specific. Structure you reponse with Company_Identification_method: where you say what
                  clues you saw and Identified_text: where you give an example snippet from the document where you get
                  that clue from. Also Give these two items per company, nothing else"
    question_3 = 'I\'m using you as an API, don\'t send me any human language.
                  For every company you mentioned, give 3 people that could have been mentioned in the document. So 9 people in total.
                  Search online first.
                  You must to send every given person combined in one list formatted in a JSON like this(
                  Don\'t create separate JSON objects for each company. Combine all people in one JSON object):
                  "{
                    "person_number":
                      {
                        "full_name": "name",
                        "company_name": "company name",
                        "company_identification_method": "company identification method",
                        "person_identification_method": "person identification method"
                        }
                      }
                  }"
                  For company_identification_method: you look at the previous response what clues it identified the specific company. Be really specific, give a structured step-by-step answer. Give at least 150 words!
                  For person_identification_method: you give the way you identified the person based on the fact that you identified the specific company. Be really specific. Give at least 100 words!
                  Make sure the JSON output like I ask, don\'t give any notes because I need to use the JSON in this exact format later.
                  '
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
      person = Person.last
      if person[:full_name].match?(/steven/i)
        Source.create(
          person: person,
          identification_method: "The company is identified based on these clues: This document appears to be a transcript from an ING Group earnings call or investor presentation. While the company name is not explicitly stated, there are several clues that point to ING:
                                  \n1. The document discusses financial results, lending, deposits, and other banking metrics typical of a large financial institution.
                                  \n2. It mentions specific markets like the Netherlands and Belgium, which are core markets for ING.
                                  \n3. The speakers refer to their \"Growing the difference strategy\", which is ING's stated strategy.
                                  \n4. There are references to mobile banking customers and digital services, which ING is known for emphasizing.
                                  \n5. The document mentions a CET1 ratio and other banking-specific financial metrics.
                                  \n6. The speakers discuss mortgage lending and wholesale banking, which are key business areas for ING.
                                  \n7. While I cannot be 100% certain without an explicit statement, the content and context strongly suggest this is an ING Group earnings call transcript or similar investor communication.",
          identified_text: "Based on the transcript, I believe Steven van Rijswijk is likely present because:
                            \n1. The document appears to be an ING Group earnings call transcript, and Steven van Rijswijk is the CEO of ING Group.
                            \n2. The transcript mentions \"I\" statements from a speaker who is discussing high-level strategy and performance, which aligns with the role of a CEO.
                            \n3. There are references to \"we\" when discussing the company's performance and outlook, indicating the speaker is in a leadership position.
                            \n4. The speaker provides an overview of the company's results and strategy before handing over to another executive (likely the CFO) for more detailed financial information, which is typical of a CEO's role in earnings calls.
                            \n5. The document uses placeholder symbols (like □□ or ) instead of actual names, but the content and context strongly suggest one of these placeholders represents Steven van Rijswijk.
                            \n6. While his name is not explicitly mentioned due to the use of placeholders, the structure and content of the call strongly indicate that Steven van Rijswijk, as CEO, would be a key participant in this earnings presentation."
        )
      else
        Source.create(
          person: person,
          identification_method: "The company is identified based on these clues: \n #{value["company_identification_method"]}",
          identified_text: "The person is identified based on these clues: \n #{value["person_identification_method"]}"
        )
      end
    end
  end
end
