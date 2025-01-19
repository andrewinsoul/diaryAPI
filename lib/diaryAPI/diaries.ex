defmodule DiaryAPI.Diaries do
  @moduledoc """
  The Diaries context.
  """

  import Ecto.Query, warn: false
  import DiaryAPIWeb.Utils, only: [filter_out_soft_delete_col: 1]
  alias DiaryAPI.Repo

  alias DiaryAPI.Diaries.Diary

  @doc """
  Returns the list of diaries.

  ## Examples

      iex> list_diaries()
      [%Diary{}, ...]

  """
  def list_diaries do
    Repo.all(Diary)
  end

  @doc """
  Gets a single diary.

  Raises `Ecto.NoResultsError` if the Diary does not exist.

  ## Examples

      iex> get_diary!(123)
      %Diary{}

      iex> get_diary!(456)
      ** (Ecto.NoResultsError)

  """
  def get_diary(id), do: Repo.get(Diary, id)

  def get_my_diary_by_id(id, user_id) do
    filter_out_soft_delete_col(Diary)
    |> where([diary], diary.user_id == ^user_id)
    |> where([diary], diary.diary_id == ^id)
    |> Repo.one()
  end

  def get_diary_by_name(name) do
    filter_out_soft_delete_col(Diary)
    |> where([diary], diary.name == ^name)
    |> Repo.all()
  end

  def get_diary_by_desc(desc_pattern) do
    filter_out_soft_delete_col(Diary)
    |> where([diary], ilike(diary.description, ^desc_pattern))
    |> Repo.all()
  end

  @doc """
  Creates a diary.

  ## Examples

      iex> create_diary(%{field: value})
      {:ok, %Diary{}}

      iex> create_diary(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_diary(attrs \\ %{}) do
    %Diary{}
    |> Diary.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a diary.

  ## Examples

      iex> update_diary(diary, %{field: new_value})
      {:ok, %Diary{}}

      iex> update_diary(diary, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_diary(%Diary{} = diary, attrs) do
    diary
    |> Diary.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Soft deletes a diary by updating the deleted_at column.

  ## Examples

      iex> delete_diary(diary)
      {:ok, %Diary{}}

      iex> delete_diary(diary)
      {:error, %Ecto.Changeset{}}

  """
  def delete_diary(%Diary{} = diary) do
    changeset =
      Ecto.Changeset.change(diary,
        deleted_at:
          NaiveDateTime.truncate(
            NaiveDateTime.utc_now(),
            :second
          )
      )

    Repo.update(changeset)
  end
end
