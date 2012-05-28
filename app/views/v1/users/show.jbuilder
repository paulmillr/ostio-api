json.call @user, :id, :email, :login, :gravatar_id, :type, :created_at, :updated_at

if @user.type == 'User'
  json.organizations @user.organizations, :id, :email, :login, :gravatar_id, :type, :created_at, :updated_at
else
  json.owners @user.owners, :id, :email, :login, :gravatar_id, :type, :created_at, :updated_at
end
