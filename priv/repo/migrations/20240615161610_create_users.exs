defmodule DiaryAPI.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :user_id, :id, primary_key: true
      add :email, :string
      add :password_hash, :string
      add :firstname, :string
      add :lastname, :string
      add :username, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
  end
end
