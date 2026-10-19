Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local


  # Local development should boot without config/master.key.
  config.require_master_key = false
  config.secret_key_base = ENV.fetch('SECRET_KEY_BASE', 'teamtable-dev-secret-key-base-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

  # Enable sending emails in development
  config.action_mailer.perform_deliveries = true

  # Care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = true
  # Don't fail the app when no SendGrid credentials are present.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Define email delivery method
  # config.action_mailer.delivery_method = :smtp
  # Write mail to tmp/mail instead of hitting SendGrid.
  config.action_mailer.delivery_method = :file
  config.action_mailer.file_settings = { location: Rails.root.join('tmp', 'mail') }

  # Define default url options
  config.action_mailer.default_url_options = { host: 'localhost', port: 3001 }


  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true


  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker


  # watch your queries while you develop your application and notify you
  # when you should add eager loading (N+1 queries),
  # when you use eager loading that is not necessary - and
  # when you should use counter caching
  # Disabled under Ruby 2.7 / this Docker image; uncomment to restore.
  # config.after_initialize do
  #   Bullet.enable = true
  #   Bullet.alert = true
  #   Bullet.bullet_logger = true
  #   Bullet.console = true
  #   # Bullet.growl = true
  #   Bullet.rails_logger = true
  #   Bullet.add_footer = true
  # end
end
