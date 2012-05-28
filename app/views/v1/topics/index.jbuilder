json.array!(@topics) do |json, topic|
  json.call topic, :id, :number, :title, :created_at, :updated_at
  json.total_posts topic.posts.count
  json.repo do |json|
    json.call topic.repo, :id, :name, :created_at, :updated_at
    json.user topic.repo.user
  end
  json.user topic.user
end 
