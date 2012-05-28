json.call @post, :id, :text, :created_at, :updated_at
json.user @post.user
json.topic do |json|
  json.call @post.topic, :id, :number, :title, :created_at, :updated_at
  json.repo do |json|
    json.call @post.topic.repo, :id, :name, :created_at, :updated_at
    json.user @post.topic.user
  end
end
