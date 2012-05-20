json.array!(@repos) do |json, repo|
  json.call repo, :id, :name, :created_at, :updated_at
  json.user @user
end 
