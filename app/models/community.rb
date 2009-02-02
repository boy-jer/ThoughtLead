class Community < ActiveRecord::Base
  has_many :users
  has_many :courses, :dependent => :destroy
  has_many :chapters, :through => :courses
  has_many :lessons, :through => :chapters

  has_many :discussions, :dependent => :destroy
  has_many :themes, :dependent => :destroy
  has_many :categories, :dependent => :destroy
  has_many :articles, :dependent => :destroy
  has_many :access_classes, :order => :position, :dependent => :destroy
  belongs_to :owner, :class_name => "User"

  validates_presence_of :host, :name
  validates_uniqueness_of :host
  validate :validate_host_restrictions

  alias_attribute :to_s, :name

  def authenticate(login, password)
    u = users.find_by_login(login)
    u && !u.disabled? && u.authenticated?(password) ? u : nil
  end

  def uses_internal_billing
    premium_link.blank? && !gateway_login.blank? && !gateway_password.blank?
  end

  private

  def validate_host_restrictions
    # Disallow host name of $app_host, (a list of things).$app_domain, and empty.
    reserved = %w(db app server test staging web ftp mail files www)
    reserved.each do | each |
      if(host == "#{each}.#{$app_host}")
        errors.add :host, "is reserved"
      end
    end

    if /[^a-zA-Z0-9\-\.]+/.match(host)
      errors.add :host
    elsif $app_host == host
      errors.add :host, "is reserved"
    elsif /[0-9]+$/.match(host)
      errors.add :host, "is reserved"
    end
  end
end
