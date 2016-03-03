class Topic < ActiveRecord::Base
  belongs_to :user
  belongs_to :repo, touch: true
  has_many :posts, dependent: :destroy

  validates :number, absence: true
  validates :title, presence: true

  before_save {
    self.number = Topic
      .maximum(:number)
      .next
  }

  default_scope {
    includes(:user, :repo)
      .order(updated_at: :desc)
  }

  def poster_emails
    posts
      .map(&:user).uniq
      .select(&:receive_emails?)
      .map(&:email)
  end

  def total_posts
    posts.count
  end
end
