class Repo < ActiveRecord::Base
  belongs_to :user
  has_many :topics, dependent: :destroy

  validates :name, presence: true

  default_scope {
    includes(:user)
      .order(updated_at: :desc)
  }
end
