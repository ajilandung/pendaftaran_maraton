class RegistrationsController < ApplicationController
  before_action :set_available_categories, only: %i[ new create ]

  def new
    @registration = Registration.new(category_id: params[:category_id])
  end

  def create
    @registration = Registration.new(registration_params)

    if @registration.save
      redirect_to @registration
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @registration = Registration.find(params[:id])
  end

  private
    # Kategori penuh tidak boleh bisa dipilih di form (R5).
    def set_available_categories
      @available_categories = Category.order(:price).reject(&:full?)
    end

    def registration_params
      params.expect(registration: [ :name, :email, :phone, :jersey_size, :category_id ])
    end
end
