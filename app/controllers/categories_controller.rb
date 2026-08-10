class CategoriesController < ApplicationController
  def index
    @categories = Category.order(:price)
  end
end
