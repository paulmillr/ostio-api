class Post < ActiveRecord::Base
  attr_accessible :created_at, :text, :topic, :user

  belongs_to :topic
  belongs_to :user
end
