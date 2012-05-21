class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :token_authenticatable, :registerable, :rememberable

  before_save :ensure_authentication_token

  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :email, :github_id, :github_token, :name, :gravatar_id, :type

  has_many :repos, dependent: :destroy
  has_many :topics, dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :login, length: {maximum: 40}
  validates :name, length: {maximum: 40}

  def to_param
    login
  end
end
