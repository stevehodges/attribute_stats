require 'attribute-stats'
namespace :db do
  namespace :stats do
    desc "list all models"
    task :list_models => :environment do
      # puts Rails.application.eager_load!
      puts ActiveRecord::Base.descendants.inspect
    end
  end
end
