class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :token_authenticatable, :registerable, :rememberable

  before_save :ensure_authentication_token

  # Setup accessible (or protected) attributes for your model
  attr_accessible :enabled_email_notifications

  has_many :repos, dependent: :destroy
  has_many :topics, dependent: :destroy
  has_many :posts, dependent: :destroy

  has_many :organization_owner_relationships, class_name: 'OrganizationOwner', foreign_key: 'organization_id', dependent: :destroy
  has_many :owners, through: :organization_owner_relationships, dependent: :destroy
  has_many :owner_organization_relationships, class_name: 'OrganizationOwner', foreign_key: 'owner_id', dependent: :destroy
  has_many :organizations, through: :owner_organization_relationships, dependent: :destroy

  validates :login, length: {maximum: 40}, presence: true
  validates :name, length: {maximum: 40}

  default_scope order: 'created_at DESC'

  def is_admin?
    login == 'paulmillr'
  end

  def receives_emails?
    enabled_email_notifications && !email.nil? && !email.empty?
  end

  def owners_emails
    if type == 'Organization'
      owners.select { |user| user.receives_emails? }.map(&:email)
    else
      if receives_emails?
        [email]
      else
        []
      end
    end
  end

  def serializable_hash(args = {})
    super(args.merge({except: [:github_token]}))
  end

  def to_param
    login
  end
end
