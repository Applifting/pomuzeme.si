web: bundle exec puma -C config/puma.rb
release: rails db:migrate
rpush: bundle exec rpush start -e $RACK_ENV -f