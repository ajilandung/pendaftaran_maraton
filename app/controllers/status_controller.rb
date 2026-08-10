class StatusController < ApplicationController
  def show
    @email = params[:email].to_s.strip

    # Email kosong diperlakukan sama seperti tanpa parameter: tampilkan form saja,
    # bukan pesan "tidak ditemukan".
    return if @email.blank?

    @searched = true
    @registration = Registration.find_by(email: @email.downcase)
  end
end
