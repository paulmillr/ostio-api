json.call @topic, :id, :number, :title, :created_at, :updated_at
json.total_posts 1  # FIXME
json.repo do |json|
  json.call @repo, :id, :name, :created_at, :updated_at
  json.user @user
end
json.user @topic.user
