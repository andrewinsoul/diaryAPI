defmodule DiaryAPI.Repo.Migrations.AddIdpColumnToUsersTable do
  use Ecto.Migration

  def change do
    try do
      set_password_hash_to_not_null = "ALTER TABLE users ALTER COLUMN password_hash SET NOT NULL"
      set_password_hash_to_null = "ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL"
      execute(set_password_hash_to_null, set_password_hash_to_not_null)
    rescue
      e -> IO.inspect(e)
    end
  end
end
