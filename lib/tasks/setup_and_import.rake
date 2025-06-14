# frozen_string_literal: true

namespace :setup do
    desc "Drop, create, migrate, seed, and import all data"
    task all: :environment do
      puts "🧨 Dropping database..."
      Rake::Task["db:drop"].invoke

      puts "📦 Creating database..."
      Rake::Task["db:create"].invoke

      puts "🛠️ Running migrations..."
      Rake::Task["db:migrate"].invoke

      puts "🌱 Seeding database..."
      Rake::Task["db:seed"].invoke

      # puts "📥 Running import tasks..."
      # Rake::Task["import:all"].invoke

      puts "✅ Full setup and import completed!"
    end
  end
