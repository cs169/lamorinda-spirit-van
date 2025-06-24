# CSV Data Encryption

This application uses encrypted CSV files to protect sensitive passenger and ride data while still allowing easy setup and deployment.

## How It Works

- **Encrypted files** (`.enc` extension) are stored in the repository
- **Unencrypted files** are generated temporarily during import and automatically cleaned up
- **Environment variable** (`CSV_ENCRYPTION_KEY`) controls access to the data

## Setup for New Team Members

1. **Get the encryption key** from a team member (shared securely, not in git)
2. **Set the environment variable**:
   ```bash
   export CSV_ENCRYPTION_KEY="your-secret-key-here"
   ```
3. **Run the setup** (this will automatically decrypt data as needed):
   ```bash
   bundle exec rake setup_and_import
   ```

## Files Involved

### Encrypted Files (stored in git):
- `db/REAL_passengers_data.csv.enc` - Encrypted passenger data
- `db/rides_jan.csv.csv.enc` - Encrypted ride data  
- `db/seed_data.rb.enc` - Encrypted seed data

### Unencrypted Files (ignored by git):
- `db/REAL_passengers_data.csv` - Temporary decrypted passenger data
- `db/rides_jan.csv` - Temporary decrypted ride data
- `db/seed_data.rb` - Temporary decrypted seed data

## Available Commands

### For Development
```bash
# Seed database (automatically handles encryption)
bundle exec rake db:seed

# Import passengers (automatically handles encryption)
bundle exec rake import:real_passengers

# Import rides and shifts (automatically handles encryption)  
bundle exec rake import:rides_shifts
```

### For Data Management
```bash
# Encrypt CSV files (run once when adding new data)
bundle exec rake encrypt:csvs

# Decrypt files for local development (if needed)
bundle exec rake encrypt:decrypt
```

## Adding New Data

1. **Update the unencrypted files** with new data
2. **Encrypt the updated files**:
   ```bash
   bundle exec rake encrypt:csvs
   ```
3. **Commit the encrypted files**:
   ```bash
   git add db/*.enc
   git commit -m "Update encrypted data files"
   ```

## Security Notes

- **Never commit unencrypted CSV files** - they're automatically ignored by git
- **Share the encryption key securely** - use encrypted messaging, not email/slack
- **Rotate the key periodically** - re-encrypt all files with a new key
- **Each environment can use different keys** - production, staging, development

## Troubleshooting

### "CSV_ENCRYPTION_KEY environment variable not set"
Set the environment variable with the key provided by your team.

### "Failed to decrypt"
- Check that your encryption key is correct
- Ensure the encrypted files haven't been corrupted
- Try getting fresh encrypted files from git

### "File not found" errors
- Run `bundle exec rake encrypt:decrypt` to restore local files
- Or run the import tasks which handle decryption automatically 