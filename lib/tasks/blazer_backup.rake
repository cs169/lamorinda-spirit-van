# frozen_string_literal: true

namespace :blazer do
    desc "Export all Blazer queries to a YAML file"
    task export: :environment do
      data = Blazer::Query.all.map do |q|
        {
          name: q.name,
          description: q.description,
          statement: q.statement,
          data_source: q.data_source
        }
      end
      File.write("blazer_queries.yml", data.to_yaml)
      puts "Exported #{data.size} queries to blazer_queries.yml"
    end

    desc "Import Blazer queries from a YAML file"
    task import: :environment do
      require "yaml"
      data = YAML.load_file("blazer_queries.yml")
      data.each do |attrs|
        Blazer::Query.find_or_create_by!(name: attrs[:name]) do |q|
          q.description = attrs[:description]
          q.statement = attrs[:statement]
          q.data_source = attrs[:data_source]
        end
      end
      puts "Imported #{data.size} queries from blazer_queries.yml"
    end
  end
