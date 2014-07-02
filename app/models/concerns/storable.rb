require 'open-uri'
module Storable
  extend ActiveSupport::Concern

  included do
    class_attribute :storable_file_column
    self.storable_file_column = 'image'
  end

  module ClassMethods
    def storable_file(name)
      storable_file_column = name
    end
  end

  def save_to_s3(force = false)
    return if !force && !image_content_changed?
    return unless ENV['AWS_ACCESS_KEY_ID']
    storage = Fog::Storage.new(
      provider: 'AWS',
      aws_access_key_id:Figaro.env.aws_access_key_id,
      aws_secret_access_key:Figaro.env.aws_secret_access_key,
      region: Figaro.env.aws_region
    )
    bucket = storage.directories.get(Figaro.env.aws_s3_bucket)
    bucket = storage.directories.create(key: Figaro.env.aws_s3_bucket) unless bucket

    save_file = self.send(storable_file_column)
    save_file = "https:#{save_file}" if save_file.match /\A\/\//
    save_file.gsub!('http://', 'https://')

    dir = self.class.to_s.tableize
    path_to_save = "#{dir}/#{self.storable_file_column.to_s}/#{self.try(:id)||0 % 1000}/#{self.try(:id)}#{Time.current.to_i}"

    file = bucket.files.create(key: path_to_save, public: true, body: open_file_over_ssl(save_file))

    if ENV['CDN_HOST'].present?
      storable_url = "#{ENV['CDN_HOST']}/#{path_to_save}"
    else
      storable_url = "#{file.public_url}?#{Time.current.to_i}"
    end
    create_thumbnail(bucket, path_to_save, storable_url)

    self.update_column(self.storable_file_column, storable_url)
  rescue => e
    Bugsnag.notify(e) if Rails.env.production?
  end

  def image_content_changed?
    new_file = self.send(storable_file_column)
    old_file = self.send("#{storable_file_column}_was")
    return true unless old_file
    return true unless Digest::MD5.hexdigest(open_file_over_ssl(new_file).read) == Digest::MD5.hexdigest(open_file_over_ssl(old_file).read)
  rescue
    return true
  else
    self[storable_file_column] = old_file
    return false
  end

  # herokuでsslをopenすると
  # OpenSSL::SSL::SSLError: SSL_connect returned=1 errno=0 state=SSLv2/v3 read server hello A: (null)
  # で落ちるので
  def open_file_over_ssl(save_file)
    uri = URI(save_file)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ssl_version = :SSLv3
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    response = http.get(uri)
    if response.code == '302'
      open_file_over_ssl(response.header['location'])
    else
      response.body
    end
  rescue
    open(save_file)
  end

  def create_thumbnail(bucket, path_to_save, save_file)
  end
end
