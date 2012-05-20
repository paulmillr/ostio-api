json.call @topic, :id, :number, :title, :created_at, :updated_at
json.repo do |json|
  json.id @repo.id
  json.url user_repo_url(@user, @repo)
end
