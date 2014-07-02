class User < ActiveRecord::Base
  include Storable
  storable_file :image
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable
  has_many :connections

  class << self
    def authentication(auth_hash, current_user = nil)
      params = auth_params(auth_hash)
      params[:image].gsub!(/_normal/, '_bigger') if params[:provider] == 'twitter'
      connection = Connection.where(provider: params[:provider], uid: params[:uid]).first_or_initialize
      user = current_user ? current_user : connection.user
      user = User.new unless user
      user.tap do |u|
        u.extend OauthSignupable # If your site do not allow signup via OAuth, remove this line.
        u.name = params[:name]
        u.nickname = params[:nickname]
        u.email = params[:email]
        u.image = params[:image]
        u.save
        u.save_to_s3(true) if u.valid?
      end

      params[:user] = user
      connection.update_attributes(params)

      return user
    rescue
      nil
    end

    def auth_params(auth_hash)
      begin
        params = {
          provider: auth_hash['provider'],
          uid: auth_hash['uid'].to_s,
          name: auth_hash['info']['name'] || auth_hash['info']['nickname'],
          email: auth_hash['info']['email'],
          nickname: auth_hash['info']['nickname'] || auth_hash['info']['name'],
          image: auth_hash['info']['image'],
          access_token: auth_hash['credentials']['token'],
          secret_token: auth_hash['credentials']['secret'],
        }
      rescue => e
        return nil
      end
    end
  end

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def email_required?
    true
  end

  def ready?
    self.name.present?
  end

  def me?(user)
    return self.id == user.try(:id)
  end

  def create_thumbnail(bucket, path_to_save, save_file)
    image = MiniMagick::Image.open(save_file)
    image.resize "50x50"
    image.quality 50
    bucket.files.create(key: path_to_save + "-50x50", public: true, body: image.to_blob)
  end

  def thumbnail_image
    "#{image}-50x50"
  end

  def image
    super
  end

  def image_with_cut_scheme
    self.image_without_cut_scheme.sub(/http(s)?:/, '') if self.image_without_cut_scheme.present?
  end
  alias_method_chain :image, :cut_scheme
end
