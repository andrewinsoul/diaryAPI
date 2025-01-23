defmodule DiaryAPI.Repo.Migrations.CreateRevokedTokens do
  use Ecto.Migration

  def change do
    create table(:revoked_tokens, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :jti, :uuid
    end
  end
end
