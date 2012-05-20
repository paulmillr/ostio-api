json.array!(@posts) do |json, post|
  json.call post, :id, :text, :created_at, :updated_at
  json.topic do |json|
    json.id @topic.id
    json.url user_repo_topic_url(@user, @repo, @topic)
  end
  json.user @user
end 
