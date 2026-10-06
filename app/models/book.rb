class Book < ApplicationRecord
  belongs_to :author

  validates :title, presence: true, uniqueness: true
  validates :published_at, presence: true
  validate :check_date

  filterrific available_filters: [ :with_name, :released_on, :with_author_name ]

  scope :with_name, ->(name) {
    where("LOWER(books.title) LIKE LOWER(?) ESCAPE '!'", "%#{sanitize_sql_like(name.to_s.strip, "!")}%")
  }

  scope :with_author_name, ->(name) {
    joins(:author).where("LOWER(authors.name) LIKE LOWER(?) ESCAPE '!'", "%#{sanitize_sql_like(name.to_s.strip, "!")}%")
  }

  scope :released_on, ->(value) {
    date = begin
      Date.iso8601(value.to_s)
    rescue Date::Error
      nil
    end
    date ? where(published_at: date) : none
  }

  private

  def check_date
    if published_at.present? && published_at > Date.current
      errors.add(:published_at, "must be today or earlier")
    end
  end
end
