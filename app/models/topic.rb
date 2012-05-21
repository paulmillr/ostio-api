class Topic < ActiveRecord::Base
  attr_accessible :created_at, :number, :repo, :user, :title, :updated_at

  belongs_to :repo
  belongs_to :user
  has_many :posts, dependent: :destroy

  def to_param
    number
  end
end
