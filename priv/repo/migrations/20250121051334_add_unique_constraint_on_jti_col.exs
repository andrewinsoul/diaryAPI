defmodule DiaryAPI.Repo.Migrations.AddUniqueConstraintOnJtiCol do
  use Ecto.Migration

  def change do
    alter table(:revoked_tokens) do
      modify :jti, :uuid, null: false
    end

    create unique_index(:revoked_tokens, [:jti])
  end
end
