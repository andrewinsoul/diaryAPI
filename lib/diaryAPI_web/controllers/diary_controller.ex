defmodule DiaryAPIWeb.DiaryController do
  use DiaryAPIWeb, :controller

  alias Ecto.Changeset
  alias DiaryAPI.Diaries
  alias DiaryAPI.Diaries.Diary
  alias DiaryAPIWeb.ResponseCodes
  alias DiaryAPIWeb.ParentJSON, as: BaseJSON

  action_fallback DiaryAPIWeb.FallbackController

  @response_codes ResponseCodes.response_codes_mapper()

  def create(conn, payload) do
    token = DiaryAPIWeb.Utils.get_token(conn)

    with {:ok, user, _claims} <- DiaryAPI.Guardian.resource_from_token(token),
         {:ok, data} <-
           Diaries.create_diary(Map.put(payload, "user_id", user.user_id)) do
      conn
      |> put_status(200)
      |> json(
        BaseJSON.show(%{
          data: %{
            diary_id: data.diary_id,
            name: data.name,
            description: data.description,
            image: data.image,
            user_id: data.user_id
          },
          code: @response_codes.created
        })
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
        |> json(
          BaseJSON.show_error(%{
            error: "you already have a diary with that name",
            code: @response_codes.duplicate
          })
        )

      {:error, %Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(
          BaseJSON.show_error(%{
            error: DiaryAPIWeb.Utils.translate_errors(changeset),
            code: @response_codes.invalid
          })
        )

      {:error, :token_expired} ->
        conn
        |> put_status(401)
        |> json(
          BaseJSON.show_error(%{
            error: "Token expired",
            code: @response_codes.unauthenticated
          })
        )

      {:error, :invalid_token} ->
        conn
        |> put_status(401)
        |> json(
          BaseJSON.show_error(%{
            error: "Invalid token",
            code: @response_codes.unauthenticated
          })
        )

      err ->
        conn
        |> put_status(500)
        |> json(
          BaseJSON.show_error(%{
            error: err,
            code: @response_codes.server_error
          })
        )
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
      |> json(
        BaseJSON.show(%{
          data: %{
            diary_id: updated_diary.diary_id,
            name: updated_diary.name,
            description: updated_diary.description,
            image: updated_diary.image,
            user_id: updated_diary.user_id
          },
          code: @response_codes.updated
        })
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
        |> json(
          BaseJSON.show_error(%{
            error: "you already have a diary with that name",
            code: @response_codes.duplicate
          })
        )

      {:error, %Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(
          BaseJSON.show_error(%{
            error: DiaryAPIWeb.Utils.translate_errors(changeset),
            code: @response_codes.invalid
          })
        )

      {:error, :token_expired} ->
        conn
        |> put_status(401)
        |> json(
          BaseJSON.show_error(%{
            error: "Token expired",
            code: @response_codes.unauthenticated
          })
        )

      {:error, :invalid_token} ->
        conn
        |> put_status(401)
        |> json(
          BaseJSON.show_error(%{
            error: "Invalid token",
            code: @response_codes.unauthenticated
          })
        )

      nil ->
        conn
        |> put_status(404)
        |> json(
          BaseJSON.show_error(%{
            code: @response_codes.not_found,
            error: "diary not found!"
          })
        )

      err ->
        conn
        |> put_status(500)
        |> json(
          BaseJSON.show_error(%{
            error: err,
            code: @response_codes.server_error
          })
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    token = DiaryAPIWeb.Utils.get_token(conn)

    with {:ok, user, _claims} <- DiaryAPI.Guardian.resource_from_token(token),
         %Diary{} = diary <-
           Diaries.get_my_diary_by_id(id, user.user_id),
         {:ok, _} <-
           Diaries.delete_diary(diary) do
      conn
      |> put_status(200)
      |> json(
        BaseJSON.show(%{
          message: "Diary was deleted successfully",
          code: @response_codes.deleted
        })
      )
    else
      {:error, :token_expired} ->
        conn
        |> put_status(401)
        |> json(
          BaseJSON.show_error(%{
            error: "Token expired",
            code: @response_codes.unauthenticated
          })
        )

      {:error, :invalid_token} ->
        conn
        |> put_status(401)
        |> json(
          BaseJSON.show_error(%{
            error: "Invalid token",
            code: @response_codes.unauthenticated
          })
        )

      nil ->
        conn
        |> put_status(404)
        |> json(
          BaseJSON.show_error(%{
            code: @response_codes.not_found,
            error: "diary not found!"
          })
        )

      err ->
        conn
        |> put_status(500)
        |> json(
          BaseJSON.show_error(%{
            error: err,
            code: @response_codes.server_error
          })
        )
    end
  end
end
