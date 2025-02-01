defmodule DiaryAPI.Diaries do
  @moduledoc """
  The Diaries context.
  """

  import Ecto.Query, warn: false
  alias DiaryAPIWeb.Filter
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
    Filter.filter_out_soft_delete_col(Diary)
    |> where([diary], diary.user_id == ^user_id)
    |> where([diary], diary.diary_id == ^id)
    |> Repo.one()
  end

  def get_diary_by_name(name) do
    Filter.filter_out_soft_delete_col(Diary)
    |> where([diary], diary.name == ^name)
    |> Repo.all()
  end

  def get_my_diaries(user_id, limit, page) do
    offset = (page - 1) * limit

    Filter.filter_out_soft_delete_col(Diary)
    |> Filter.paginate(%{"user_id" => user_id}, limit, offset)
    |> Repo.all()
  end

  def count_my_diaries(user_id) do
    case Filter.count_util(
           Filter.filter_out_soft_delete_col(Diary),
           %{"user_id" => user_id},
           :diary_id
         )
         |> Repo.one() do
      total_count when is_integer(total_count) ->
        {:ok, total_count}

      _ ->
        {:error}
    end
  end

  def get_diaries(limit, page) do
    offset = (page - 1) * limit

    Filter.filter_out_soft_delete_col(Diary)
    |> Filter.paginate(%{"is_private" => false}, limit, offset)
    |> Repo.all()
  end

  def count_diaries() do
    case Filter.count_util(
           Filter.filter_out_soft_delete_col(Diary),
           %{"is_private" => false},
           :diary_id
         )
         |> Repo.one() do
      total_count when is_integer(total_count) ->
        {:ok, total_count}

      _ ->
        {:error}
    end
  end

  def search_diaries(params) do
    limit = params["limit"]
    page = params["page"]

    model =
      Filter.filter_out_soft_delete_col(Diary)
      |> where([diary], diary.is_private == false)

    cond do
      !is_nil(params["desc"]) and !is_nil(params["name"]) ->
        model
        |> Filter.paginate(
          %{
            "name" => params["name"],
            "description" => params["desc"]
          },
          limit,
          page
        )
        |> Repo.all()

      !is_nil(params["desc"]) ->
        model
        |> Filter.paginate(
          %{
            "description" => params["desc"]
          },
          limit,
          page
        )
        |> Repo.all()

      !is_nil(params["name"]) ->
        model
        |> Filter.paginate(
          %{
            "name" => params["name"],
            "description" => params["desc"]
          },
          limit,
          page
        )
        |> Repo.all()

      true ->
        get_diaries(limit, page)
    end
  end

  def count_search_diaries(params) do
    model =
      Filter.filter_out_soft_delete_col(Diary)
      |> where([diary], diary.is_private == false)

    cond do
      !is_nil(params["desc"]) and !is_nil(params["name"]) ->
        count =
          Filter.count_util(
            model,
            %{
              "name" => params["name"],
              "description" => params["desc"]
            },
            :diary_id
          )
          |> Repo.one()

        {:ok, count}

      !is_nil(params["desc"]) ->
        count =
          Filter.count_util(
            model,
            %{
              "description" => params["desc"]
            },
            :diary_id
          )
          |> Repo.one()

        {:ok, count}

      !is_nil(params["name"]) ->
        count =
          Filter.count_util(
            model,
            %{
              "name" => params["name"],
              "description" => params["desc"]
            },
            :diary_id
          )
          |> Repo.one()

        {:ok, count}

      true ->
        count_diaries()
    end
  end

  def search_my_diaries(params, user_id) do
    limit = params["limit"]
    page = params["page"]

    model =
      Filter.filter_out_soft_delete_col(Diary)
      |> where([diary], diary.user_id == ^user_id)

    cond do
      !is_nil(params["desc"]) and !is_nil(params["name"]) ->
        model
        |> Filter.paginate(
          %{
            "name" => params["name"],
            "description" => params["desc"]
          },
          limit,
          page
        )
        |> Repo.all()

      !is_nil(params["desc"]) ->
        model
        |> Filter.paginate(
          %{
            "description" => params["desc"]
          },
          limit,
          page
        )
        |> Repo.all()

      !is_nil(params["name"]) ->
        model
        |> Filter.paginate(
          %{
            "name" => params["name"]
          },
          limit,
          page
        )
        |> Repo.all()

      true ->
        get_my_diaries(user_id, limit, page)
    end
  end

  def count_search_my_diaries(params, user_id) do
    model =
      Filter.filter_out_soft_delete_col(Diary)
      |> where([diary], diary.user_id == ^user_id)

    cond do
      !is_nil(params["desc"]) and !is_nil(params["name"]) ->
        count =
          Filter.count_util(
            model,
            %{
              "name" => params["name"],
              "description" => params["desc"]
            },
            :diary_id
          )
          |> Repo.one()

        {:ok, count}

      !is_nil(params["desc"]) ->
        count =
          Filter.count_util(
            model,
            %{
              "description" => params["desc"]
            },
            :diary_id
          )
          |> Repo.one()

        {:ok, count}

      !is_nil(params["name"]) ->
        count =
          Filter.count_util(
            model,
            %{
              "name" => params["name"],
              "description" => params["desc"]
            },
            :diary_id
          )
          |> Repo.one()

        {:ok, count}

      true ->
        count_my_diaries(user_id)
    end
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
