class Repo < ActiveRecord::Base
  attr_accessible :name, :user_id

  belongs_to :user
  has_many :topics, dependent: :destroy

  def to_param
    name
  end
end
