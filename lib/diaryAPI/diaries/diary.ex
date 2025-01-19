defmodule DiaryAPI.Diaries.Diary do
  alias DiaryAPI.Entries.Entry
  alias DiaryAPI.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:diary_id, :id, autogenerate: true}

  schema "diaries" do
    field :name, :string
    field :description, :string
    field :image, :string
    belongs_to :user, User, foreign_key: :user_id, references: :user_id
    has_many :entries, Entry, foreign_key: :entry_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(diary, attrs) do
    diary
    |> cast(attrs, [:name, :image, :description, :user_id])
    |> validate_required([:name, :description])
    |> unique_constraint(:user_diary_unique, name: :user_diary_unique_index)
    # |> foreign_key_constraint(:user_id)
  end
end
