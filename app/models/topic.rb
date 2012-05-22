class Topic < ActiveRecord::Base
  attr_accessible :title

  belongs_to :repo
  belongs_to :user
  has_many :posts, dependent: :destroy

  before_create :increment_number

  def to_param
    number
  end

  private

  def increment_number
    last = repo.topics.last
    self.number = (last ? last.number : 0) + 1
  end
end
