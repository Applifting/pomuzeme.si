web: bundle exec puma -C config/puma.rb
release: rails db:migrate
sidekiq: bundle exec sidekiq -q default -q receiver_queue -q mailers -c 2