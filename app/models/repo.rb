class Repo < ActiveRecord::Base
  attr_accessible :name

  belongs_to :user
  has_many :topics, dependent: :destroy

  before_create :validate_unique_name

  validate :name, presence: true

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
