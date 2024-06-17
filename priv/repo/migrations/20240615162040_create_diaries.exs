defmodule DiaryAPI.Repo.Migrations.CreateDiaries do
  use Ecto.Migration

  def change do
    create table(:diaries, primary_key: false) do
      add :diary_id, :bigserial, primary_key: true
      add :name, :string
      add :image, :string
      add :description, :string
      add :user_id, references(:users, column: :user_id, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:diaries, [:name, :user_id], name: :user_diary_unique_index)
  end
end
