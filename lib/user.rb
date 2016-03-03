class User < ActiveRecord::Base
  has_many :repos, dependent: :destroy
  has_many :topics, dependent: :destroy
  has_many :posts, dependent: :destroy

  has_and_belongs_to_many :organizations,
    class_name: 'User', join_table: :organization_owners,
    foreign_key: :owner_id, association_foreign_key: :organization_id

  has_and_belongs_to_many :owners,
    class_name: 'User', join_table: :organization_owners,
    foreign_key: :organization_id, association_foreign_key: :owner_id

  validates :login, presence: true
  validates_inclusion_of :typeof, in: %w[ User Organization ]

  def self.latest(count = 24)
    limit(count)
      .order(created_at: :desc)
      .where(typeof: 'User')
      .where.not(github_token: nil)
  end

  def self.from_resource(client, attrs = { })
    user = User.find_or_create_by({
      github_id: client.id
    })

    user.attributes = client.to_hash
      .slice(* %i[ login name email avatar_url ])
      .merge(attrs)

    user.save!
    user
  end

  def url
    'https://github.com/' + login
  end

  def admin?
    'paulmillr' == login
  end

  def org?
    'Organization' == typeof
  end

  def receive_emails?
    enabled_email_notifications &&
    !email.nil? &&
    !email.empty?
  end

  def owners_emails
    users = if org?
      owners
    else
      [ self ]
    end

    users
      .select(&:receive_emails?)
      .map(&:email)
  end

  def sync_orgs!
    Octokit.orgs(login).each do |org|
      organizations << User.from_resource(org, {
        typeof: 'Organization'
      })
    end

    self
  end

  def sync_repos!
    old = repos.pluck(:name)
    new = Octokit.repos(login).map(&:name)

    repos.where(name: old - new).destroy_all
    repos.create! ((new - old).map { |repo|
      { name: repo }
    })

    self
  end

  def serializable_hash(options = null)
    options ||= { }
    options[:except] = :github_token

    super
  end
end
