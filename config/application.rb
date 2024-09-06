require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Walltaker
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.eager_load_paths << Rails.root.join("scrubbers")
    config.eager_load_paths << Rails.root.join("services")
    Rails.application.config.hosts << "joi.how"
    Rails.application.config.hosts << "walltaker.joi.how"
    Rails.application.config.hosts << "walltaker-heroku-24-6dcd77a4ae7b.herokuapp.com"
    Rails.application.config.hosts << "10.244.14.67"
    Rails.application.config.hosts << "walltaker-master-39nrv.ondigitalocean.app"
    Rails.application.config.hosts << "walltaker-7e4cf22c7c3d.herokuapp.com"
  end
end
