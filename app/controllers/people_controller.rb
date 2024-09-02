class PeopleController < ApplicationController
  def index
    @people = Person.all
    @sources = Source.all
  end

  def show
    @person = Person.find(params[:id])
  end

end
