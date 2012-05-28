json.array!(@repos) do |json, repo|
  json.call repo, :id, :github_id, :name, :created_at, :updated_at
  json.user repo.user
end 
