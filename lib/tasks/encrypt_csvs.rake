require_relative '../csv_encryption'

namespace :encrypt do
  desc "Encrypt CSV files and seed data for secure storage in repository"
  task csvs: :environment do
    puts "Encrypting CSV files..."
    
    # Check if encryption key is set
    begin
      CsvEncryption.encryption_key
    rescue => e
      puts "ERROR: #{e.message}"
      puts "Please set the CSV_ENCRYPTION_KEY environment variable:"
      puts "export CSV_ENCRYPTION_KEY='your-secret-key-here'"
      exit 1
    end
    
    files_to_encrypt = [
      {
        source: Rails.root.join('db', 'REAL_passengers_data.csv'),
        encrypted: Rails.root.join('db', 'REAL_passengers_data.csv.enc')
      },
      {
        source: Rails.root.join('db', 'rides_jan.csv'),
        encrypted: Rails.root.join('db', 'rides_jan.csv.enc')
      },
      {
        source: Rails.root.join('db', 'seed_data.rb'),
        encrypted: Rails.root.join('db', 'seed_data.rb.enc')
      }
    ]
    
    files_to_encrypt.each do |file_info|
      if File.exist?(file_info[:source])
        CsvEncryption.encrypt_file(file_info[:source], file_info[:encrypted])
      else
        puts "WARNING: Source file not found: #{file_info[:source]}"
      end
    end
    
    puts "\nEncryption complete!"
    puts "You can now:"
    puts "1. Add the .enc files to git: git add db/*.enc"
    puts "2. Remove the original files from git: git rm db/REAL_passengers_data.csv db/rides_jan.csv db/seed_data.rb"
    puts "3. Add the original files to .gitignore"
    puts "4. Share the CSV_ENCRYPTION_KEY securely with your team"
  end
  
  desc "Decrypt CSV files for local development (temporary files)"
  task decrypt: :environment do
    puts "Decrypting CSV files for local use..."
    
    begin
      CsvEncryption.encryption_key
    rescue => e
      puts "ERROR: #{e.message}"
      puts "Please set the CSV_ENCRYPTION_KEY environment variable"
      exit 1
    end
    
    files_to_decrypt = [
      {
        encrypted: Rails.root.join('db', 'REAL_passengers_data.csv.enc'),
        decrypted: Rails.root.join('db', 'REAL_passengers_data.csv')
      },
      {
        encrypted: Rails.root.join('db', 'rides_jan.csv.enc'),
        decrypted: Rails.root.join('db', 'rides_jan.csv')
      },
      {
        encrypted: Rails.root.join('db', 'seed_data.rb.enc'),
        decrypted: Rails.root.join('db', 'seed_data.rb')
      }
    ]
    
    files_to_decrypt.each do |file_info|
      if File.exist?(file_info[:encrypted])
        CsvEncryption.decrypt_file(file_info[:encrypted], file_info[:decrypted])
      else
        puts "WARNING: Encrypted file not found: #{file_info[:encrypted]}"
      end
    end
    
    puts "\nDecryption complete!"
    puts "Original files restored for local development."
    puts "Remember: These decrypted files should not be committed to git."
  end
end 