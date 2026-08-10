class Admin::RegistrationsController < ApplicationController
  ADMIN_PASSWORD = Rails.application.credentials.admin_password ||
    raise("admin_password belum ada di credentials. Set lewat: ruby bin/rails credentials:edit")

  http_basic_authenticate_with name: "admin", password: ADMIN_PASSWORD

  before_action :set_registration, only: %i[ mark_paid mark_unpaid destroy ]

  def index
    @registrations = Registration.includes(:category).order(created_at: :desc)
    @categories = Category.order(:price)
  end

  def mark_paid
    @registration.update!(paid: true)
    redirect_to admin_registrations_path, notice: "#{@registration.name} ditandai lunas."
  end

  def mark_unpaid
    @registration.update!(paid: false)
    redirect_to admin_registrations_path, notice: "#{@registration.name} ditandai belum lunas."
  end

  def destroy
    @registration.destroy!
    redirect_to admin_registrations_path, notice: "Pendaftaran #{@registration.name} dihapus."
  end

  private
    def set_registration
      @registration = Registration.find(params[:id])
    end
end
