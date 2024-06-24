defmodule DiaryAPI.Repo.Migrations.EnforceSomeColumnsToNotNullable do
  use Ecto.Migration

  def change do
    try do
      set_firstname_to_not_null = "ALTER TABLE users ALTER COLUMN firstname SET NOT NULL"
      set_firstname_to_null = "ALTER TABLE users ALTER COLUMN firstname DROP NOT NULL"
      execute(set_firstname_to_not_null, set_firstname_to_null)

      set_lastname_to_not_null = "ALTER TABLE users ALTER COLUMN lastname SET NOT NULL"
      set_lastname_to_null = "ALTER TABLE users ALTER COLUMN lastname DROP NOT NULL"
      execute(set_lastname_to_not_null, set_lastname_to_null)

      set_email_to_not_null = "ALTER TABLE users ALTER COLUMN email SET NOT NULL"
      set_email_to_null = "ALTER TABLE users ALTER COLUMN email DROP NOT NULL"
      execute(set_email_to_not_null, set_email_to_null)

      set_username_to_not_null = "ALTER TABLE users ALTER COLUMN username SET NOT NULL"
      set_username_to_null = "ALTER TABLE users ALTER COLUMN username DROP NOT NULL"
      execute(set_username_to_not_null, set_username_to_null)

      set_password_hash_to_not_null = "ALTER TABLE users ALTER COLUMN password_hash SET NOT NULL"
      set_password_hash_to_null = "ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL"
      execute(set_password_hash_to_not_null, set_password_hash_to_null)
    rescue
      e -> IO.inspect(e)
    end
  end
end
