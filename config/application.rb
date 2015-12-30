require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/lib/oss)

    config.assets.paths << "#{Rails}/vendor/assets/fonts"
    config.assets.digest = true
    config.serve_static_files = true

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV['OSS_SMTP_SERVER'],
      port: ENV['OSS_SMTP_PORT'],
      authentication: ENV['OSS_SMTP_AUTH_METHOD'],
      user_name: ENV['OSS_SMTP_USERNAME'],
      password: ENV['OSS_SMTP_PASSWORD'],
    }

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    if ENV.has_key?('OSS_AWS_ACCESS_ID') && !ENV['OSS_AWS_ACCESS_ID'].empty? &&
       ENV.has_key?('OSS_AWS_SECRET_KEY') && !ENV['OSS_AWS_SECRET_KEY'].empty?
      cred = {
        bucket: ENV['OSS_IMAGE_BUCKET_NAME']
      }
    else
      cred = {
        bucket: ENV['OSS_IMAGE_BUCKET_NAME'],
        access_key_id: ENV['OSS_AWS_ACCESS_ID'],
        secret_access_key: ENV['OSS_AWS_SECRET_KEY'],
      }
    end

    if ENV['OSS_REGION'] == 'us-east-1'
      s3_host_name = 's3.amazonaws.com'
    else
      s3_host_name = "s3-#{ENV['OSS_REGION']}.amazonaws.com"
    end

    config.paperclip_defaults = {
      s3_host_name: s3_host_name,
      storage: :s3,
      s3_region: ENV['OSS_REGION'],
      s3_credentials: cred,
    }

    def resource_endpoint
      bucket_name = ENV['OSS_IMAGE_BUCKET_NAME']
      if ENV.has_key?('OSS_CDN_BASE_URL') && !ENV['OSS_CDN_BASE_URL'].empty?
        url = "#{ENV['OSS_CDN_BASE_URL']}"
      else
        if ENV['OSS_USE_S3_STATIC_HOSTING'] == '1'
          url = "http://#{bucket_name}"
        else
          if ENV['OSS_REGION'] == 'us-east-1'
            url = "https://#{bucket_name}.s3.amazonaws.com"
          else
            url = "https://#{bucket_name}.s3-#{ENV['OSS_REGION']}.amazonaws.com"
          end
        end
      end
      url
    end

    def upload_endpoint
      bucket_name = ENV['OSS_BUCKET_NAME']
      if ENV['OSS_REGION'] == 'us-east-1'
        url = "https://#{bucket_name}.s3.amazonaws.com"
      else
        url = "https://#{bucket_name}.s3-#{ENV['OSS_REGION']}.amazonaws.com"
      end
      url
    end

    config.oss_resource_endpoint = self.resource_endpoint
    config.oss_upload_endpoint = self.upload_endpoint
  end
end
