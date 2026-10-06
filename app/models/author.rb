class Author < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :name, presence: true, uniqueness: true
  has_many :books

  filterrific available_filters: [ :with_name ]

  scope :with_name, ->(name) {
    where("LOWER(authors.name) LIKE LOWER(?) ESCAPE '!'", "%#{sanitize_sql_like(name.to_s.strip, "!")}%")
  }
end
