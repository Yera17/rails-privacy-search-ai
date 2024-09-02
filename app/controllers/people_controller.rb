class PeopleController < ApplicationController
  def index
    @people = Person.where(document_id: params[:document_id])
  end

  def show
    @person = Person.find(params[:id])
    @sources = Source.where(person_id: @person.id)
  end
end
