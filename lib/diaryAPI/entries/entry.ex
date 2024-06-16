defmodule DiaryAPI.Entries.Entry do
  alias DiaryAPI.Diaries.Diary
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:entry_id, :id, autogenerate: true}

  schema "entries" do
    field :title, :string
    field :image, :string
    field :content, :string
    field :is_private, :boolean, default: false
    belongs_to :diary, Diary, foreign_key: :diary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:title, :image, :content, :is_private])
    |> validate_required([:title, :content])
    |> unique_constraint(:diary_entry_unique, name: :diary_entry_unique_index)
  end
end
