require 'json'
require 'bundler'
require 'dotenv'
Dotenv.load

Bundler.require
Dir['./lib/*'].each &method(:require)

disable :show_exceptions

set :protection, except: :json_csrf
set :database_file, 'db/config.yml'

before do
  path = request.path_info
  path.gsub! /^\/v\d/, '' # remove version
  path.chomp! '/' # strip trailing slash

  if request.body.size != 0
    request.body.rewind
    params.merge! JSON.parse(request.body.read)
  end

  params.symbolize_keys!
end

before do

end

before '/users/me*' do
  @_login = me.login
end

after do
  ActiveRecord::Base.connection.close

  headers({
    'Access-Control-Allow-Credentials' => 'true',
    'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE',
    'Access-Control-Allow-Origin' => ENV['OSTIO_ORIGIN'],
    'Access-Control-Max-Age' => '1728000'
  })

  if status >= 400
    codes = self.class::HTTP_STATUS_CODES
    body(message: codes[status] || '')
  end

  content_type :json
  body(body.to_json)
end

#=======

options '*' do
  headers({
    'Allow' => 'HEAD, GET, PUT, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers' => 'Content-Type, Cache-Control, Accept'
  })

  200
end

get '/' do
  # list declared routes
  self.class.routes.map { |_, signatures|
    signatures.map do |signature|
      signature[3].instance_variable_get :@route_name
    end
  }.flatten
end

get '/posts' do
  Post.latest.as_json({
    include: [ :user, topic: { include: :repo } ]
  })
end

get '/search' do
  posts = Post.arel_table
  query = '%' + params[:query] + '%'

  Post
    .where(posts[:text].matches(query))
    .order(updated_at: :desc)
    .as_json({
      include: [ :user, topic: { include: :repo } ]
    })
end

# Authentication API
# ==================

get '/auth' do
  redirect to Octokit.authorize_url(ENV['GITHUB_APP_ID'], {
    redirect_uri: ENV['OSTIO_API_REDIRECT']
  })
end

get '/auth-callback' do
  error(400) unless params.key? :code

  token = Octokit.exchange_code_for_token(
    params[:code],
    ENV['GITHUB_APP_ID'],
    ENV['GITHUB_APP_SECRET']
  )[:access_token]

  client = Octokit::Client
    .new(access_token: token)
    .user

  user = User.from_resource(client, {
    github_token: token,
    typeof: client.type
  })

  user.sync_orgs!
  user.sync_repos!

  redirect to ENV['OSTIO_CLIENT_REDIRECT'] +
    "?access_token=#{token}&login=#{user.login}"
end

# =====================
# Authorization helpers
# =====================

helpers {
  def is_me!
    error(403) unless me.admin? || me == user
  end

  def is_my! model
    error(403) unless me.admin? || me == model.user
  end
}

# =========
# Users API
# =========

_user = '/users/:user_name'

helpers {
  def me
    @_me ||=
      User.find_by(github_token: params[:access_token]) or
      error(401)
  end

  def user
    @_user ||=
      User.find_by(login: @_login || params[:user_name]) or
      error(404)
  end
}

# =========

get '/users' do
  User.latest
end

get _user do
  user.as_json(include: %i[
    organizations owners
  ])
end

put _user do
  is_me!
  user.attributes = params.slice(:enabled_email_notifications)
  user.save ? 204 : 400
end

post _user + '/sync_repos' do
  is_me!
  user.sync_repos!
  204
end

delete _user do
  is_me!
  user.destroy
  204
end

# ================
# Repositories API
# ================

_repos = _user + '/repos'
_repo = _repos + '/:repo_name'

helpers {
  def repo
    @_repo ||=
      user.repos.find_by(name: params[:repo_name]) or
      error(404)
  end
}

# ================

get _repos do
  user.repos
end

get _repo do
  repo.as_json(include: :user)
end

delete _repo do
  is_my! repo
  repo.destroy
  204
end

# ==========
# Topics API
# ==========

_topics = _repo + '/topics'
_topic = _topics + '/:topic_id'

helpers {
  def topic
    @_topic ||=
      repo.topics.find_by(number: params[:topic_id]) or
      error(404)
  end
}

# ==========

get _topics do
  repo.topics.as_json({
    methods: :total_posts,
    include: [ :user, repo: { include: :user } ]
  })
end

post _topics do
  topic = repo.topics.new(params.slice(:title))
  topic.user = me
  topic.save or error(400)
  topic.as_json
end

get _topic do
  topic
end

put _topic do
  is_my! topic
  topic.attributes = params.slice(:name)
  topic.save ? 204 : 400
end

delete _topic do
  is_my! topic
  topic.destroy
  204
end

# =========
# Posts API
# =========

_posts = _topic + '/posts'
_post = _posts + '/:post_id'

helpers {
  def post
    @_post ||=
      topic.posts.find_by(id: params[:post_id]) or
      error(404)
  end

  def send_mail(post)
    title = "Re: [#{ repo.name }] #{ topic.title }"
    reply = [
      'ost.io',
      '@' + repo.user.login,
      repo.name,
      'topics',
      topic.number
    ].join '/'

    message = """
      <!DOCTYPE html>
      <meta charset='utf-8'>
      <title>#{ title }</title>

      <p><b>#{ post.user.login } said:</b>
      <p>#{ post.text }<p>&mdash;
      <p>Reply to this post at <a href='http://#{ reply }'>#{ reply }</a>.
      <p>You can unsubscribe via <a href='http://ost.io/settings'>settings</a>.
    """

    Thread.new {
      emails = user
        .owners_emails
        .concat(topic.poster_emails)
        .uniq - [ post.user.email ]

      emails.each do |email|
        Mail.deliver {
          from 'noreply@ost.io'
          to email
          subject title
          body message
        }
      end
    }
  end
}

# =========

get _posts do
  topic.posts.as_json(include: [
    :user,
    topic: { include: %i[ user repo ] }
  ])
end

post _posts do
  post = topic.posts.new(params.slice(:text))
  post.user = me
  post.save or error(400)

  send_mail(post)
  201
end

get _post do
  post
end

put _post do
  is_my! post
  post.attributes = params.slice(:text)
  post.save ? 204 : 400
end

delete _post do
  is_my! post
  post.destroy
  204
end
