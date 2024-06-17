defmodule DiaryAPI.Diaries do
  @moduledoc """
  The Diaries context.
  """

  import Ecto.Query, warn: false
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
  def get_diary!(id), do: Repo.get!(Diary, id)

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
  Deletes a diary.

  ## Examples

      iex> delete_diary(diary)
      {:ok, %Diary{}}

      iex> delete_diary(diary)
      {:error, %Ecto.Changeset{}}

  """
  def delete_diary(%Diary{} = diary) do
    Repo.delete(diary)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking diary changes.

  ## Examples

      iex> change_diary(diary)
      %Ecto.Changeset{data: %Diary{}}

  """
  def change_diary(%Diary{} = diary, attrs \\ %{}) do
    Diary.changeset(diary, attrs)
  end
end
