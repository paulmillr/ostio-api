json.call @topic, :id, :number, :title, :created_at, :updated_at
json.total_posts 1  # FIXME
json.repo do |json|
  json.call @topic.repo, :id, :name, :created_at, :updated_at
  json.user @topic.repo.user, :id, :email, :login, :gravatar_id, :type, :created_at, :updated_at
end
json.user @topic.user, :id, :email, :login, :gravatar_id, :type, :created_at, :updated_at
