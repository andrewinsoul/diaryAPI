defmodule DiaryAPIWeb.DiaryController do
  use DiaryAPIWeb, :controller

  import DiaryAPIWeb.Utils, only: [get_token: 1, decode_token: 1]
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

  def fetch_my_diaries(conn, _params) do
    token = get_token(conn)

    with {:ok, claims} <- decode_token(token),
         diaries <- Diaries.get_my_diaries(claims["sub"]) do
      conn
      |> put_status(200)
      |> render(:index, diaries: diaries)
    else
      err ->
        conn
        |> put_status(500)
        |> render(:show_error,
          error: err,
          code: @response_codes.server_error
        )
    end
  end

  def fetch_diaries(conn, _params) do
    diaries = Diaries.get_diaries()

    if diaries do
      conn
      |> put_status(200)
      |> render(:index, diaries: diaries)
    else
      conn
      |> put_status(500)
      |> render(:show_error,
        error: "can not fetch diaries at this moment, try again!",
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
