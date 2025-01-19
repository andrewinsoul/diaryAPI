defmodule DiaryAPIWeb.DiaryController do
  use DiaryAPIWeb, :controller

  alias Ecto.Changeset
  alias DiaryAPI.Diaries
  alias DiaryAPI.Diaries.Diary
  alias DiaryAPIWeb.ResponseCodes

  action_fallback DiaryAPIWeb.FallbackController

  def create(conn, payload) do
    token = DiaryAPIWeb.Utils.get_token(conn)

    with {:ok, user, _claims} <- DiaryAPI.Guardian.resource_from_token(token),
         {:ok, data} <-
           Diaries.create_diary(Map.put(payload, "user_id", user.user_id)) do
      conn
      |> put_status(200)
      |> json(%{
        message: "Success",
        data: %{
          diary_id: data.diary_id,
          name: data.name,
          description: data.description,
          image: data.image,
          user_id: data.user_id
        },
        code: ResponseCodes.response_codes_mapper().created
      })
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
        |> render(:show_error, %{
          error: "you already have a diary with that name",
          code: ResponseCodes.response_codes_mapper().duplicate
        })

      {:error, %Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:show_error, %{
          error: DiaryAPIWeb.Utils.translate_errors(changeset),
          code: ResponseCodes.response_codes_mapper().invalid
        })

      {:error, :token_expired} ->
        conn
        |> put_status(401)
        |> json(%{
          error: "Token expired",
          code: ResponseCodes.response_codes_mapper().unauthenticated
        })

      {:error, :invalid_token} ->
        conn
        |> put_status(401)
        |> json(%{
          error: "Invalid token",
          code: ResponseCodes.response_codes_mapper().unauthenticated
        })

      _ ->
        conn
        |> put_status(500)
        |> render(:show_error, %{code: "INTERNAL SERVER ERROR"})
    end
  end

  def show(conn, %{"id" => id}) do
    diary = Diaries.get_diary(id)
    render(conn, :show, diary: diary)
  end

  def update(conn, %{"id" => id}) do
    token = DiaryAPIWeb.Utils.get_token(conn)
    diary_params = conn.body_params

    with {:ok, user, _claims} <- DiaryAPI.Guardian.resource_from_token(token),
         %Diary{} = diary <-
           Diaries.get_my_diary_by_id(id, user.user_id),
         {:ok, %Diary{} = updated_diary} <-
           Diaries.update_diary(diary, diary_params) do
      conn
      |> put_status(200)
      |> json(%{
        message: "Diary was updated successfully",
        data: %{
          diary_id: updated_diary.diary_id,
          name: updated_diary.name,
          description: updated_diary.description,
          image: updated_diary.image,
          user_id: updated_diary.user_id
        },
        code: ResponseCodes.response_codes_mapper().updated
      })
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
        |> render(:show_error, %{
          error: "you already have a diary with that name",
          code: ResponseCodes.response_codes_mapper().duplicate
        })

      {:error, %Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:show_error, %{
          error: DiaryAPIWeb.Utils.translate_errors(changeset),
          code: ResponseCodes.response_codes_mapper().invalid
        })

      {:error, :token_expired} ->
        conn
        |> put_status(401)
        |> json(%{
          error: "Token expired",
          code: ResponseCodes.response_codes_mapper().unauthenticated
        })

      {:error, :invalid_token} ->
        conn
        |> put_status(401)
        |> json(%{
          error: "Invalid token",
          code: ResponseCodes.response_codes_mapper().unauthenticated
        })

      nil ->
        conn
        |> put_status(404)
        |> render(:show_error, %{
          code: ResponseCodes.response_codes_mapper().not_found,
          error: ["diary not found!"]
        })

      err ->
        conn
        |> put_status(500)
        |> render(:show_error, %{code: "INTERNAL SERVER ERROR", error: err})
    end
  end

  def delete(conn, %{"id" => id}) do
    diary = Diaries.get_diary(id)

    with {:ok, %Diary{}} <- Diaries.delete_diary(diary) do
      send_resp(conn, :no_content, "")
    end
  end
end
