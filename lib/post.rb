class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic, touch: true

  validates :text, presence: true

  default_scope {
    includes(:user, topic: %i[ user repo ])
  }

  def self.latest(count = 20)
    limit(count).order(created_at: :desc)
  end
end
