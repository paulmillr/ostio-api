json.array!(@repos) do |json, repo|
  json.call repo, :id, :name, :created_at, :updated_at
  json.user do |json|
    json.id @user.id
    json.url user_url(@user)
  end
end 
