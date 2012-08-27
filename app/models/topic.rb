class Topic < ActiveRecord::Base
  attr_accessible :title

  belongs_to :repo
  belongs_to :user
  has_many :posts, dependent: :destroy

  validates :title, presence: true

  before_create :increment_number

  default_scope order: 'created_at DESC'

  def self.popular(count = 20)
    groupped = Post
      .group(:topic_id)
      .order(:count_topic_id).reverse_order
      .limit(count)
      .count(:topic_id)
    self.where(id: groupped.keys)
  end

  def poster_emails
    posts.map(&:user).uniq.select { |user|
      user.enabled_email_notifications && !user.email.nil? && !user.email.empty?
    }.map(&:email)
  end

  def to_param
    number
  end

  private

  def increment_number
    last = repo.topics.first
    self.number = (last ? last.number : 0) + 1
  end
end
