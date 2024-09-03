class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @document = Document.new
  end
  def test_particles
  end
end
