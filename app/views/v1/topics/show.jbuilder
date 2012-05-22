json.call @topic, :id, :number, :title, :created_at, :updated_at
json.repo do |json|
  json.call @repo, :id, :name, :created_at, :updated_at
  json.user @user
end
json.user topic.user
