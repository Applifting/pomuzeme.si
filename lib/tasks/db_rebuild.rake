# frozen_string_literal: true

namespace :db do
  desc 'Rebuild database'
  task :rebuild, [] => :environment do
    Rake::Task['db:drop'].execute
    Rake::Task['db:create'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['db:seed'].execute
  end
end