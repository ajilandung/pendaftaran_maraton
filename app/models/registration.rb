class Registration < ApplicationRecord
  JERSEY_SIZES = %w[S M L XL].freeze

  belongs_to :category

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :jersey_size, presence: true, inclusion: { in: JERSEY_SIZES }

  # Hanya saat pembuatan. Kalau berlaku juga saat update, panitia tidak bisa
  # menandai lunas sebuah pendaftaran di kategori yang sudah penuh.
  validate :category_must_have_room, on: :create

  private
    def category_must_have_room
      return if category.blank?

      errors.add(:category, "sudah penuh") if category.full?
    end
end
