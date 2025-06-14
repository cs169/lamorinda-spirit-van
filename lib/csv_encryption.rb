# frozen_string_literal: true

require "openssl"
require "base64"

module CsvEncryption
  class << self
    def encryption_key
      key = ENV["CSV_ENCRYPTION_KEY"]
      raise "CSV_ENCRYPTION_KEY environment variable not set" unless key

      # Ensure key is exactly 32 bytes for AES-256
      Digest::SHA256.digest(key)
    end

    def encrypt_file(input_path, output_path)
      raise "Input file not found: #{input_path}" unless File.exist?(input_path)

      content = File.read(input_path)
      encrypted_content = encrypt_string(content)

      File.write(output_path, encrypted_content)
      puts "Encrypted #{input_path} -> #{output_path}"
    end

    def decrypt_file(encrypted_path, output_path = nil)
      raise "Encrypted file not found: #{encrypted_path}" unless File.exist?(encrypted_path)

      encrypted_content = File.read(encrypted_path)
      decrypted_content = decrypt_string(encrypted_content)

      if output_path
        File.write(output_path, decrypted_content)
        puts "Decrypted #{encrypted_path} -> #{output_path}"
        output_path
      else
        # Return a temporary file path
        temp_file = Tempfile.new(["decrypted_csv", ".csv"])
        temp_file.write(decrypted_content)
        temp_file.close
        temp_file.path
      end
    end

    def decrypt_to_tempfile(encrypted_path)
      raise "Encrypted file not found: #{encrypted_path}" unless File.exist?(encrypted_path)

      encrypted_content = File.read(encrypted_path)
      decrypted_content = decrypt_string(encrypted_content)

      temp_file = Tempfile.new(["decrypted_csv", ".csv"])
      temp_file.write(decrypted_content)
      temp_file.close
      temp_file.path
    end

    private
    def encrypt_string(plaintext)
      cipher = OpenSSL::Cipher.new("AES-256-CBC")
      cipher.encrypt
      cipher.key = encryption_key
      iv = cipher.random_iv

      encrypted = cipher.update(plaintext) + cipher.final

      # Combine IV and encrypted data, then base64 encode
      Base64.strict_encode64(iv + encrypted)
    end

    def decrypt_string(encrypted_data)
      data = Base64.strict_decode64(encrypted_data)

      # Extract IV (first 16 bytes) and encrypted content
      iv = data[0, 16]
      encrypted_content = data[16..-1]

      cipher = OpenSSL::Cipher.new("AES-256-CBC")
      cipher.decrypt
      cipher.key = encryption_key
      cipher.iv = iv

      cipher.update(encrypted_content) + cipher.final
    end
  end
end
