class Post < ActiveRecord::Base
  attr_accessible :text

  belongs_to :topic
  belongs_to :user
end
