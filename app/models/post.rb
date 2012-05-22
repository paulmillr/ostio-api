class Post < ActiveRecord::Base
  attr_accessible :text, :topic

  belongs_to :topic
  belongs_to :user
end
