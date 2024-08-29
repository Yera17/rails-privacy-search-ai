class DocumentsController < ApplicationController
  def create
    uploaded_file = File.open(document_params[:file])
    file_content = uploaded_file.read

    @document = Document.new(file_name: document_params[:file_name], text: file_content, user: current_user)
    if @document.save
      # @ai_response = search(@document)
      redirect_to document_people_path(@document)
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

  def search(document)
    question_1 = "Document text: #{document[:text]} Question: This is an document about a company. What are the 3 most
                  likely companies that the document is about. Every name prefix it with Company_name: . Only give the
                  3 companies with Company_name: nothing else"
    question_2 = "For every company you find, explain what clues from the document made you think it could be that
                  company, be really specific. Structure you reponse with Identification_method: where you say what
                  clues you saw and Identified_text: where you give an example snippet from the document where you get
                  that clue from. Also Give these two items per company, nothing else"
    question_3 = 'can you make a variable that contains the following text in ruby : "For every company you mentioned,
                  give a list of 5 people that could have been mentioned in the document. I\'m using you as an API,
                  don\'t send me any human language.
                  I\'d like to have a list of people formatted In a JSON like this:
                  {
                    "person_1":
                      {
                      "full_name": "name",
                      "company_name": "company name",
                      "identification_method": "identification method",
                      "identified_text": "identified text"
                      }
                  }
                  For identification_method first summarize shortly how you
                  identified the company and then how you identified the person.'
    system_prompt = "You are a helpful assistant that helps us to check whether a document is anonymized well enough.
                    We give you a file that is redacted. Your role is to find clues that eventually identify the
                    names of the specific persons of the document. You can use all the tools you want to reach
                    your goal. You can search online!"

    client = OpenAI::Client.new

    response_1 = client.chat(parameters: {
      model: "gpt-4o",
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: question_1 }
      ]
    })

    # output_1 = response_1["choices"][0]["message"]["content"]

    # response_2 = client.chat(parameters: {
    #   model: "gpt-3.5-turbo",
    #   messages: [
    #     { role: "system", content: system_prompt },
    #     { role: "user", content: question_1 },
    #     { role: "assistant", content: output_1 },
    #     { role: "user", content: question_2 }
    #   ]
    # })

    # output_2 = response_2["choices"][0]["message"]["content"]

    # response_3 = client.chat(parameters: {
    #   model: "gpt-3.5-turbo",
    #   messages: [
    #     { role: "system", content: system_prompt },
    #     { role: "user", content: question_1 },
    #     { role: "assistant", content: output_1 },
    #     { role: "user", content: question_2 },
    #     { role: "assistant", content: output_2 },
    #     { role: "user", content: question_3 }
    #   ]
    # })

    return response_1["choices"][0]["message"]["content"]
  end

  # search(text)
end
