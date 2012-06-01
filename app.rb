require 'ick'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'sequel'

Ick.sugarize

DB = Sequel.connect('mysql://ostio:ostio@localhost/ostio')

DB.create_table? :authorizations do
  primary_key :id
  String
end

DB.create_table? :users do
  primary_key :id
  String :login
  String :name
  String :gravatar_id
  String :type, default: 'User'
  index :login
end

DB.create_table? :repos do
  primary_key :id
  foreign_key :user_id, :users
  String :name
  index :name
end

DB.create_table? :threads do
  primary_key :id
  Integer :number
  foreign_key :repo_id, :repos
  String :title
  index :number
end

DB.create_table? :posts do
  primary_key :id
  foreign_key :thread_id, :threads
  foreign_key :user_id, :users
  String :text
  timestamp :created_at
end

module API
end

class API::Authorization < Sequel::Model

end

class API::User < Sequel::Model
  one_to_many :repos
  one_to_many :posts

  set_allowed_columns :name

  def self.get_by_login(login)
    filter(login: login).first
  end

  def to_hash
    {id: id, login: login, name: name, gravatar_id: gravatar_id, type: type}
  end

  def validate
    # errors.add :login, 'can\'t be empty' if login.to_s.size == 0
  end
end

class API::Repo < Sequel::Model
  many_to_one :user
  one_to_many :threads

  def self.get_by_login_and_repo_name(login, repo_name)
    API::User
      .filter(login: login).first
      .maybe.repos_dataset.filter(name: repo_name).first
  end

  def self.of_user(login)
    API::User.filter(login: login).first
      .maybe.repos_dataset.map(&:to_compact_hash)
  end

  def to_compact_hash
    {id: id, name: name}
  end

  def to_hash
    {id: id, user: user.to_hash, name: name}
  end

  def validate
    errors.add :name, 'can\'t be empty' if name.to_s.size == 0
  end
end

class API::Thread < Sequel::Model
  many_to_one :repo
  one_to_many :posts

  # lolz.
  def self.get_by_login_repo_name_and_thread_number(login, repo_name, thread_number)
    API::User
      .filter(login: login).first
      .maybe.repos_dataset.filter(name: repo_name).first
      .maybe.threads_dataset.filter(number: thread_number).first
  end

  def self.of_repo(login, repo_name)
    API::Repo.get_by_login_and_repo_name(
      login, repo_name
    ).maybe.threads_dataset.map(&:to_compact_hash)
  end

  def to_compact_hash
    {number: number, title: title}
  end

  def to_hash
    {number: number, title: title, repo: repo.to_hash}
  end

  def validate
    errors.add :title, 'can\'t be empty' if title.to_s.size == 0
  end
end

class API::Post < Sequel::Model
  many_to_one :thread
  many_to_one :user

  def self.of_thread(login, repo_name, thread_number)
    API::Thread.get_by_login_repo_name_and_thread_number(
      login, repo_name, thread_number
    ).maybe.posts_dataset.map(&:to_compact_hash)
  end

  def to_compact_hash
    {user: user.to_hash, text: text, created_at: created_at}
  end

  def to_hash
    {
      thread: thread.to_hash, user: user.to_hash,
      text: text, created_at: created_at
    }
  end

  def validate
    errors.add :text, 'can\'t be empty' if text.to_s.size == 0
  end
end

class App < Sinatra::Base
  register Sinatra::RestAPI
  register Sinatra::CrossOrigin

  enable cross_origin
  enable :raise_errors, :logging
  enable :show_exceptions

  rest_create '/authorizations/' do
    API::Authorizations.new
  end

  rest_resource '/authorizations/:id' do |id|
    API::Authorizations.filter(id: id).first
  end

  rest_resource '/users/:login' do |login|
    API::User.get_by_login(login)
  end

  rest_get '/users/:login/repos/' do |login|
    API::Repo.of_user(login)
  end

  rest_create '/users/:login/repos/' do |login|
    let(API::User.get_by_login(login)) do |user|
      API::Repo.new(user: user) 
    end
  end

  rest_resource '/users/:login/repos/:repo_name' do |login, repo_name|    
    API::Repo.get_by_login_and_repo_name(login, repo_name)
  end

  rest_get '/users/:login/repos/:repo_name/threads/' do |login, repo_name|
    API::Thread.of_repo(login, repo_name)
  end

  rest_create '/users/:login/repos/:repo_name/threads/' do |login, repo_name|
    let(API::Repo.get_by_login_and_repo_name(login, repo_name)) do |repo|
      API::Thread.new(repo: repo)
    end
  end

  rest_resource '/users/:login/repos/:repo_name/threads/:thread_number' do |login, repo_name, thread_number|
    API::Thread.get_by_login_repo_name_and_thread_number(
      login, repo_name, thread_number
    )
  end

  rest_get '/users/:login/repos/:repo_name/threads/:thread_number/posts/' do |login, repo_name, thread_number|
    API::Post.of_thread(login, repo_name, thread_number)
  end

  rest_create '/users/:login/repos/:repo_name/threads/:thread_number/posts/' do |login, repo_name, thread_number|
    let(
      API::Thread.get_by_login_repo_name_and_thread_number(
        login, repo_name, thread_number
      )
    ) { |thread| API::Post.new(thread: thread) }
  end

  rest_resource '/users/:login/repos/:repo_name/threads/:thread_number/posts/:post_id' do |login, repo_name, thread_number, post_id|
    API::Post.filter(id: post_id).first
  end

  run! if app_file == $0
end
