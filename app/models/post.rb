class Post < ActiveRecord::Base
  attr_accessible :text

  belongs_to :topic
  belongs_to :user

  validates :text, presence: true

  def self.latest
    includes(:user, topic: [repo: :user])
      .order(:updated_at).reverse_order()
      .limit(20)
  end
end
