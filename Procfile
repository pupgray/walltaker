release: rake db:migrate assets:precompile
web: bundle exec puma -C config/puma.rb
background_jobs: bundle exec rake solid_queue:start
