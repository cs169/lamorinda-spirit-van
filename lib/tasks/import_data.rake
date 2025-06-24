# frozen_string_literal: true

require "csv"

namespace :import do
  desc "Import data from a CSV file into a specified model"
  task :data, [:file_path, :model_name] => :environment do |task, args|
    file_path = args[:file_path].present? ? Rails.root.join(args[:file_path]) : nil
    model_name = args[:model_name]

    if file_path.nil? || model_name.nil?
      puts "Usage: rake import:data[file_path,model_name]"
      puts "Example: rake import:data['db/passengers.csv','Passenger']"
      exit
    end

    unless File.exist?(file_path)
      puts "CSV file not found at #{file_path}"
      exit
    end

    begin
      model_class = model_name.constantize
    rescue NameError
      puts "#{model_name} is not a valid ActiveRecord model."
      exit
    end

    puts "Importing data from #{file_path} into #{model_name}..."

    CSV.foreach(file_path, headers: true) do |row|
      attributes = row.to_h.transform_keys { |key| key.parameterize.underscore }
      formatted_attributes = {}

      # Process attributes dynamically, handling special cases
      attributes.each do |key, value|
        column_type = model_class.columns_hash[key]&.type

        formatted_attributes[key] =
          case column_type
          when :integer then value.to_i if value.present?
          when :decimal, :float then value.to_f if value.present?
          when :boolean then value.downcase.in?(%w[true t yes y 1]) if value.present?
          when :date then Date.strptime(value, "%m/%d/%Y") rescue nil if value.present?
          when :datetime then DateTime.parse(value) rescue nil if value.present?
          else value.presence
          end
      end

      puts "Row Data: #{formatted_attributes}"
      model_class.create!(formatted_attributes)
    end

    puts "Import complete!"
  end
end
