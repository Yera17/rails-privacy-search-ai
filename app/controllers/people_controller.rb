class PeopleController < ApplicationController
  def index
    @people = Person.where(document_id: params[:document_id])
  end

  def show
    @person = Person.find(params[:id])
  end

end
