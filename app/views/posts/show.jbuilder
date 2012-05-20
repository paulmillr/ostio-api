json.call @post, :id, :text, :created_at, :updated_at
json.user @post.user
json.topic do |json|
  json.id @topic.id
  json.url user_repo_topic_url(@user, @repo, @topic)
end
