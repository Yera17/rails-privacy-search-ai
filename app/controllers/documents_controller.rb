class DocumentsController < ApplicationController
  def create
    uploaded_file = File.open(document_params[:file])
    file_content = uploaded_file.read

    @document = Document.new(file_name: document_params[:file_name], text: file_content, user: current_user)
    if @document.save
      # search(@document)
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

  text = "Q&A
[OCCUPATION_1]
Thank you. Ladies and gentlemen, if you would like to ask a question, please press one on your telephone keypad. And in
the interest of time, we kindly ask each [OCCUPATION_2] to limit yourself to two questions only. Thank you. We will now take our fi rst
question from [NAME_1] of [ORGANIZATION_1], your line is open. Please go ahead.
[NAME_2] ([ORGANIZATION_1])
Yes. Good morning, gentlemen. Thanks for taking my questions. So the fi rst one will be on net interest income. Looking at the
2 main moving parts, so lending NII and liability NII. Although lending NII, obviously, very strong growth on the volume side, it
sounds that you, or at least, I am more positive on the lending NII development going forward. Are you also a bit more positive
4
Transcript [OCCUPATION_2] call [DATE_INTERVAL_1]
on lending volumes for the rest of the year and also on lending margin developments? That will be the fi rst sub-question on NII.
And then on NII again, on page 22, you provide a very interesting sensitivity. Last quarter, you told us that based on the curve
of [DATE_INTERVAL_2], you expect to be between 100 and 110 bps on the liability margin. I see a delta based on the current curve of
[MONEY_1] on interest income from the replicating income in [DATE_INTERVAL_3], which will be about 9 bps on the total customer deposits.
So my question is, based on the current curve, are you maybe a little bit more also positive on this range of 100-110 bps? Are
we more likely to be on the high end of this range based on the current curve? That's the question. And then, just a very tiny
question on the asset sale. So well, the Wholesale book is down by [MONEY_2], but how much is the kind of eff ect of the asset sales
in, say, [DATE_INTERVAL_4] or [DATE_INTERVAL_5]? I just wanted to get the full picture on an underlying basis. And also you talk about SRTs in the past and
just wondering where you are on that. Thank you very much.
[NAME_3]
All right, thanks. I will do the one on asset sales and NII, and [NAME_GIVEN_1] will talk about the graph on page 22. Talking about the NII,
I think we also are quite positive. And if you look at the volumes in mortgages, to start with, the volumes were good. You also
saw, if you look at the market share of the new production in [LOCATION_COUNTRY_1], it was 16% and higher, where our total market
share is around 13%. So we're doing very well. That also has to do, by the way, with the strength of our digital channel and
interaction with our [OCCUPATION_3]. So we're doing very well. I'm very happy with that. You also, by the way, see it in our number 1
NPS position in this market. And also you see gradually increasing volumes in [LOCATION_COUNTRY_2] and [LOCATION_COUNTRY_3]. And those markets are
recovering a bit slower on the mortgage side. So they are still quite some way off of where their mortgage sales or house sales
were in [DATE_INTERVAL_6] and [DATE_INTERVAL_7] and before that time. So that recovery is slower, but also in that slower market, we're doing well. So that
gives us also confi dence for the future.
In Wh[ORGANIZATION_2], we saw also lending growth, but we also have a number of underwrites and loan sales. And therefore, I
link question 1 and question 3: we had about [MONEY_3] in loan sales this quarter and therefore you see the total going down. But
we also have a number of committed facilities which are undrawn. So we grow, but you don't see it in the numbers because
it's not drawn at this point in time. But we see in our pipelines of deals that the market is becoming stronger. So from a volume
point of view, we have a positive viewpoint based on what we see, the market shares in the market and how the market in
mortgages and Wholesale Banking are recovering. If you look at the margins, in Wholesale Banking, you already see a bit
of margin expansion, ok? it's only 1 bps, but it gives at least- it has been stable- but you now see the growth is coming back.
When liquidity in the market should become a bit lower with quantitative tightening, that should have a positive impact on it.
Let's see where that goes. But we saw, at least for this quarter, a limited increase. And the deposit margin is holding up well in
line with what we expected. But I'll let [NAME_GIVEN_1] talk about page 22.
[NAME_4]
Thank you [NAME_GIVEN_2]. We wanted to provide this mechanical replication of the yield curve for the [LOCATION_1] deposit book. I think
this is one determinant of where our NII for liability will go. But I think there are 3 other developments. I think volume is clearly
one in terms of deposits. And you can see that we are quite optimistic about our momentum in terms of volumes, given what
we see in [DATE_INTERVAL_8] and also [DATE_INTERVAL_4]. It will also be determined by the mix of our deposits between term deposits, savings and current
account. And what we also saw is that the "

  def search(text)
    question_1 = "Document text: #{text} Question: This is an document about a company. What are the 3 most likely companies that the document is about. Every name prefix it with Company_name: . Only give the 3 companies with Company_name: nothing else"
    question_2 = "For every company you find, explain what clues from the document made you think it could be that company, be really specific. Structure you reponse with Identification_method: where you say what clues you saw and Identified_text: where you give an example snippet from the document where you get that clue from. Also Give these two items per company, nothing else"
    question_3 = 'can you make a variable that contains the following text in ruby : "For every company you mentioned, give a list of 5 people that could have been mentioned in the document. I\'m using you as an API, don\'t send me any human language.
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
                  For identification_method first summarize shortly how you identified the company and then how you identified the person.

                  '
    system_prompt = "You are a helpful assistant that helps us to check whether a document is anonymized well enough. We give you a file that is redacted. Your role is to find clues that eventually identify the names of the specific persons of the document. You can use all the tools you want to reach your goal. You can search online!"

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
