# frozen_string_literal: true

require "csv"

namespace :import do
    desc "Import all data in below order"
    task all: :environment do
      Rake::Task["import:real_passengers"].invoke
      Rake::Task["import:rides_month"].invoke("jan")
      Rake::Task["blazer:import"].invoke
      puts "✅ All import tasks have finished successfully!"
    end
  end
