class Organizationing < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  belongs_to :organization, class_name: 'User'
end
