defmodule DiaryAPI.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries, primary_key: false) do
      add :entry_id, :bigserial, primary_key: true
      add :title, :string
      add :image, :string
      add :content, :string
      add :is_private, :boolean, default: false, null: false
      add :diary_id, references(:diaries, column: :diary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:entries, [:title, :diary_id], name: :diary_entry_unique_index)
  end
end
