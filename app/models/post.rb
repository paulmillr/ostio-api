class Post < ActiveRecord::Base
  attr_accessible :text

  belongs_to :topic
  belongs_to :user

  validates :text, presence: true

  default_scope order: 'created_at'
end
