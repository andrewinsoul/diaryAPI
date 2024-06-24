defmodule DiaryAPI.Accounts.User do
  alias DiaryAPI.Diaries.Diary
  use Ecto.Schema
  import Ecto.Changeset
  import Bcrypt, only: [hash_pwd_salt: 1]

  @primary_key {:user_id, :id, autogenerate: true}
  schema "users" do
    field :username, :string
    field :email, :string
    field :password_hash, :string
    field :firstname, :string
    field :lastname, :string

    # Virtual fields:
    field :password, :string, virtual: true

    # Associations
    has_many :diaries, Diary, foreign_key: :diary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :firstname, :lastname, :username])
    |> validate_required([:email, :firstname, :lastname, :username])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/)
    |> validate_length(:password, min: 8)
    |> insert_password_hash
  end

  defp insert_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: user_password}} ->
        put_change(changeset, :password_hash, hash_pwd_salt(user_password))

      _ ->
        changeset
    end
  end
end
