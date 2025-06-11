# frozen_string_literal: true

namespace :import do
    desc "Import all data in below order"
    task all: :environment do
      Rake::Task["import:fake_addresses"].invoke
      Rake::Task["import:real_passengers"].invoke
      Rake::Task["import:fake_rides"].invoke
      Rake::Task["blazer:import"].invoke
      puts "✅ All import tasks have finished successfully!"
    end
  end
