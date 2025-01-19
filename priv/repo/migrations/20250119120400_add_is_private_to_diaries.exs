defmodule DiaryAPI.Repo.Migrations.AddIsPrivateToDiaries do
  use Ecto.Migration

  def change do
    alter table(:diaries) do
      add :is_private, :boolean, default: false
    end
  end
end
