defmodule DiaryAPIWeb.UserController do
  use DiaryAPIWeb, :controller

  alias Ecto.Changeset
  alias DiaryAPI.Accounts
  alias DiaryAPI.Accounts.User
  alias DiaryAPI.Guardian

  action_fallback DiaryAPIWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, user_params) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(201)
      |> render(:show, %{token: token, code: "CREATED"})
    else

      {:error, %Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:show_error, %{error: translate_errors(changeset), code: "INVALID_INPUT"})
      _ ->
        conn
        |> put_status(500)
        |> render(:show_error, %{code: "INTERNAL SERVER ERROR"})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, token, _claims} <- Accounts.token_sign_in(email, password) do
      conn |> render(:show, %{token: token, code: "LOGIN"})
    else
      _ -> conn |> put_status(401) |> render(:show_error, %{error: "wrong credentials supplied", code: "AUTH FAILED"});

    end
  end

  def login(conn, _) do
    conn |> put_status(400) |> render(:show_error, %{code: "INVALID", error: "Invalid input, email and password is required"});
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Gettext.dgettext(DiaryAPIWeb.Gettext, "errors", msg, opts)

    end)
  end
end
