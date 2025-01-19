defmodule DiaryAPI.Repo.Migrations.AddDeletedAtToDiaries do
  use Ecto.Migration

  def change do
    alter table(:diaries) do
      add :deleted_at, :naive_datetime
    end
  end
end
