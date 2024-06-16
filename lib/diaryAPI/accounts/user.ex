defmodule DiaryAPI.Accounts.User do
  alias DiaryAPI.Diaries.Diary
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:user_id, :id, autogenerate: true}
  schema "users" do
    field :username, :string
    field :email, :string
    field :password_hash, :string
    field :firstname, :string
    field :lastname, :string
    has_many :diaries, Diary, foreign_key: :diary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password_hash, :firstname, :lastname, :username])
    |> validate_required([:email, :password_hash, :firstname, :lastname, :username])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end
end
