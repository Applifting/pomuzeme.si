web: bundle exec puma -C config/puma.rb
release: rails db:migrate
rpush: bundle exec rpush start -e $RACK_ENV -f
sidekiq: bundle exec sidekiq -q default -q receiver_queue -q mailers -c 2