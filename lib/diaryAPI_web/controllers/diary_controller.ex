defmodule DiaryAPIWeb.DiaryController do
  use DiaryAPIWeb, :controller

  import DiaryAPIWeb.Utils, only: [get_token: 1, decode_token: 1, max_limit: 1]
  alias Ecto.Changeset
  alias DiaryAPI.Diaries
  alias DiaryAPI.Diaries.Diary
  alias DiaryAPIWeb.ResponseCodes

  action_fallback DiaryAPIWeb.FallbackController

  @response_codes ResponseCodes.response_codes_mapper()

  def create(conn, payload) do
    token = get_token(conn)

    with {:ok, claims} <- decode_token(token),
         {:ok, data} <-
           Diaries.create_diary(Map.put(payload, "user_id", claims["sub"])) do
      conn
      |> put_status(200)
      |> render(:show,
        diary: data,
        code: @response_codes.created
      )
    else
      {:error,
       %Changeset{} = %Ecto.Changeset{
         errors: [
           user_diary_unique:
             {"has already been taken",
              [constraint: :unique, constraint_name: "user_diary_unique_index"]}
         ]
       }} ->
        conn
        |> put_status(409)
        |> render(:show_error,
          error: "you already have a diary with that name",
          code: @response_codes.duplicate
        )

      {:error, %Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:show_error,
          error: DiaryAPIWeb.Utils.translate_errors(changeset),
          code: @response_codes.invalid
        )

      {:error, :token_expired} ->
        conn
        |> put_status(401)
        |> render(:show_error,
          error: "Token expired",
          code: @response_codes.unauthenticated
        )

      {:error, :invalid_token} ->
        conn
        |> put_status(401)
        |> render(:show_error,
          error: "Token expired",
          code: @response_codes.unauthenticated
        )

      err ->
        conn
        |> put_status(500)
        |> render(:show_error,
          error: err,
          code: @response_codes.server_error
        )
    end
  end

  def show(conn, %{"id" => id}) do
    diary = Diaries.get_diary(id)
    render(conn, :show, diary: diary)
  end

  @spec fetch_my_diaries(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def fetch_my_diaries(conn, params) do
    token = get_token(conn)
    limit = max_limit(Map.get(params, "limit", "50"))
    page = Map.get(params, "page", "1")

    with {:ok, claims} <- decode_token(token),
         diaries when is_list(diaries) <-
           Diaries.get_my_diaries(
             String.to_integer(claims["sub"]),
             String.to_integer(limit),
             String.to_integer(page)
           ),
         {:ok, total_count} <- Diaries.count_my_diaries(claims["sub"]) do
      conn
      |> put_status(200)
      |> render(:index, diaries: diaries, limit: limit, page: page, total: total_count)
    else
      {:error, :token_expired} ->
        conn
        |> put_status(401)
        |> render(:show_error,
          error: "Token expired",
          code: @response_codes.unauthenticated
        )

      {:error, :invalid_token} ->
        conn
        |> put_status(401)
        |> render(:show_error,
          error: "Invalid token",
          code: @response_codes.unauthenticated
        )

      _ ->
        conn
        |> put_status(500)
        |> render(:show_error,
          error: "A server error happened",
          code: @response_codes.server_error
        )
    end
  end

  @spec fetch_diaries(any(), map()) :: Plug.Conn.t()
  def fetch_diaries(conn, params) do
    limit = max_limit(Map.get(params, "limit", "50"))
    page = Map.get(params, "page", "1")

    with diaries when is_list(diaries) <-
           Diaries.get_diaries(String.to_integer(limit), String.to_integer(page)),
         {:ok, diaries_count} <- Diaries.count_diaries() do
      conn
      |> put_status(200)
      |> render(:index, diaries: diaries, limit: limit, page: page, total: diaries_count)
    else
      _ ->
        conn
        |> put_status(500)
        |> render(:show_error,
          error: "can not fetch diaries at this moment, try again!",
          code: @response_codes.server_error
        )
    end
  end

  @spec search_my_diaries(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def search_my_diaries(conn, params) do
    token = get_token(conn)
    limit = max_limit(Map.get(params, "limit", "50"))
    page = Map.get(params, "page", "1")
    name = Map.get(params, "name", nil)
    desc = Map.get(params, "desc", nil)

    with {:ok, claims} <- decode_token(token),
         diaries when is_list(diaries) <-
           Diaries.search_my_diaries(
             %{
               "name" => name,
               "desc" => desc,
               "limit" => String.to_integer(limit),
               "page" => String.to_integer(page)
             },
             String.to_integer(claims["sub"])
           ),
         {:ok, total_count} <-
           Diaries.count_search_my_diaries(%{"desc" => desc, "name" => name}, claims["sub"]) do
      conn
      |> put_status(200)
      |> render(:index, diaries: diaries, limit: limit, page: page, total: total_count)
    else
      {:error, :token_expired} ->
        conn
        |> put_status(401)
        |> render(:show_error,
          error: "Token expired",
          code: @response_codes.unauthenticated
        )

      {:error, :invalid_token} ->
        conn
        |> put_status(401)
        |> render(:show_error,
          error: "Invalid token",
          code: @response_codes.unauthenticated
        )

      _ ->
        conn
        |> put_status(500)
        |> render(:show_error,
          error: "A server error happened",
          code: @response_codes.server_error
        )
    end
  end

  @spec search_diaries(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def search_diaries(conn, params) do
    limit = max_limit(Map.get(params, "limit", "50"))
    page = Map.get(params, "page", "1")
    name = Map.get(params, "name", nil)
    desc = Map.get(params, "desc", nil)

    with diaries when is_list(diaries) <-
           Diaries.search_diaries(%{
             "name" => name,
             "desc" => desc,
             "limit" => String.to_integer(limit),
             "page" => String.to_integer(page)
           }),
         {:ok, total_count} <-
           Diaries.count_search_diaries(%{"desc" => desc, "name" => name}) do
      conn
      |> put_status(200)
      |> render(:index, diaries: diaries, limit: limit, page: page, total: total_count)
    else
      {:error, :token_expired} ->
        conn
        |> put_status(401)
        |> render(:show_error,
          error: "Token expired",
          code: @response_codes.unauthenticated
        )

      {:error, :invalid_token} ->
        conn
        |> put_status(401)
        |> render(:show_error,
          error: "Invalid token",
          code: @response_codes.unauthenticated
        )

      _ ->
        conn
        |> put_status(500)
        |> render(:show_error,
          error: "A server error happened",
          code: @response_codes.server_error
        )
    end
  end

  # def fetch_diaries(conn) do
  # end

  def update(conn, %{"id" => id}) do
    token = get_token(conn)
    diary_params = conn.body_params

    with {:ok, claims} <- decode_token(token),
         %Diary{} = diary <-
           Diaries.get_my_diary_by_id(id, claims["sub"]),
         {:ok, %Diary{} = updated_diary} <-
           Diaries.update_diary(diary, diary_params) do
      conn
      |> put_status(200)
      |> render(:show, diary: updated_diary, code: @response_codes.updated)
    else
      {:error,
       %Changeset{} = %Ecto.Changeset{
         errors: [
           user_diary_unique:
             {"has already been taken",
              [constraint: :unique, constraint_name: "user_diary_unique_index"]}
         ]
       }} ->
        conn
        |> put_status(409)
        |> render(:show_error,
          error: "you already have a diary with that name",
          code: @response_codes.duplicate
        )

      {:error, %Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:show_error,
          error: DiaryAPIWeb.Utils.translate_errors(changeset),
          code: @response_codes.invalid
        )

      {:error, :token_expired} ->
        conn
        |> put_status(401)
        |> render(:show_error,
          error: "Token expired",
          code: @response_codes.unauthenticated
        )

      {:error, :invalid_token} ->
        conn
        |> put_status(401)
        |> render(:show_error,
          error: "Invalid token",
          code: @response_codes.unauthenticated
        )

      nil ->
        conn
        |> put_status(404)
        |> render(:show_error,
          code: @response_codes.not_found,
          error: "diary not found!"
        )

      err ->
        conn
        |> put_status(500)
        |> render(:show_error,
          error: err,
          code: @response_codes.server_error
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    token = get_token(conn)

    with {:ok, claims} <- decode_token(token),
         %Diary{} = diary <-
           Diaries.get_my_diary_by_id(id, claims["sub"]),
         {:ok, _} <-
           Diaries.delete_diary(diary) do
      conn
      |> put_status(200)
      |> render(:delete)
    else
      {:error, :token_expired} ->
        conn
        |> put_status(401)
        |> render(:show_error,
          error: "Token expired",
          code: @response_codes.unauthenticated
        )

      {:error, :invalid_token} ->
        conn
        |> put_status(401)
        |> render(:show_error,
          error: "Invalid token",
          code: @response_codes.unauthenticated
        )

      nil ->
        conn
        |> put_status(404)
        |> render(:show_error,
          code: @response_codes.not_found,
          error: "diary not found!"
        )

      err ->
        conn
        |> put_status(500)
        |> render(:show_error,
          error: err,
          code: @response_codes.server_error
        )
    end
  end
end
