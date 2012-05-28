json.array!(@posts) do |json, post|
  json.call post, :id, :text, :created_at, :updated_at
  json.user post.user, :id, :email, :login, :gravatar_id, :type, :created_at, :updated_at
  json.topic do |json|
    json.call post.topic, :id, :number, :title, :created_at, :updated_at
    json.repo do |json|
      json.call post.topic.repo, :id, :name, :created_at, :updated_at
      json.user post.topic.repo.user, :id, :email, :login, :gravatar_id, :type, :created_at, :updated_at
    end
  end
end 
