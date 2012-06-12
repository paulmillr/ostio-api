class Repo < ActiveRecord::Base
  attr_accessible :name

  belongs_to :user
  has_many :topics, dependent: :destroy

  before_create :validate_unique_name

  validate :name, presence: true

  default_scope order: 'updated_at DESC'

  def self.popular(count = 20)
    groupped = Topic
      .group(:repo_id)
      .order(:count_repo_id).reverse_order
      .limit(count)
      .count(:repo_id)
    self.where(id: groupped.keys)
  end

  def to_param
    name
  end

  private

  def validate_unique_name
    if user.repos.pluck(:name).include?(name)
      errors.add(:name, 'must be unique to user')
    end
  end
end
