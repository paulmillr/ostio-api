class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :login, :password, :password_confirmation, :remember_me

  has_many :services, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :repos, dependent: :destroy

  validates :login, length: {maximum: 40}
  validates :fullname, length: {maximum: 40}

  def to_param
    login
  end
end
