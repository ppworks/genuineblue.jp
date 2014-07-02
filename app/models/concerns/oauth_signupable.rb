module OauthSignupable
  extend ActiveSupport::Concern

  def self.extended(base)
    super
    base.class.before_validation :__skip_confirmation!
  end

  protected
  def password_required?
    false
  end

  def email_required?
    false
  end

  private
  def __skip_confirmation!
    if respond_to?(:skip_confirmation!)
      skip_confirmation!
    end
  end
  module ClassMethods
  end
end
