class Topic < ActiveRecord::Base
  attr_accessible :created_at, :number, :repo_id, :title, :updated_at

  belongs_to :repo
  has_many :posts, dependent: :destroy

  def to_param
    number
  end
end
