defmodule DiaryAPIWeb.UserController do
  use DiaryAPIWeb, :controller
  plug Ueberauth

  alias DiaryAPI.RevokedToken.Token
  alias DiaryAPIWeb.ResponseCodes
  alias Ecto.Changeset
  alias DiaryAPI.Accounts
  alias DiaryAPI.Accounts.User
  alias DiaryAPI.Guardian

  import DiaryAPIWeb.Utils, only: [translate_errors: 1, revoke_token: 1, get_token: 1]

  action_fallback DiaryAPIWeb.FallbackController

  @response_codes ResponseCodes.response_codes_mapper()

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, user_params) do
    if !Map.get(user_params, "password") do
      conn
      |> put_status(400)
      |> render(:show_error, %{
        code: @response_codes.invalid,
        error: "password is required"
      })
    else
      with {:ok, %User{} = user} <- Accounts.create_user(user_params),
           {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
        conn
        |> put_status(201)
        |> render(:show, %{token: token, code: @response_codes.created})
      else
        {:error, %Changeset{} = changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(:show_error, %{
            error: translate_errors(changeset),
            code: @response_codes.invalid
          })

        _ ->
          conn
          |> put_status(500)
          |> render(:show_error, %{code: @response_codes.server_error})
      end
    end
  end

  def request(_conn, _user_params) do
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _user_params) do
    user_data = %{
      email: auth.info.email,
      firstname: auth.info.first_name,
      lastname: auth.info.last_name,
      username: auth.info.email |> String.split("@") |> hd,
      password_hash: nil
    }

    with {:ok, token, _claims} <- Accounts.findOrCreate(user_data) do
      conn |> render(:oauth_show, %{token: token, redirect_uri: "FRONTEND_URI"})
    else
      {:code, "METHOD NOT ALLOWED", message: "account cannot authenticate with OAUTH"} ->
        conn
        |> put_status(403)
        |> render(:show_error, %{
          error:
            "Account registered with password, reset your password if you cannot recall your password",
          code: "BAD REQUEST"
        })

      _error ->
        conn
        |> put_status(401)
        |> render(:show_error, %{
          error: "an error occured during oauth authentication",
          code: "OAUTH FAILED"
        })
    end
  end

  def callback(conn, _user_params) do
    conn
    |> put_status(401)
    |> render(:show_error, %{
      error: "an error occured during callback phase of oauth authentication",
      code: "OAUTH FAILED"
    })
  end

  def login(conn, %{"identity" => email, "password" => password}) do
    with {:ok, token, _claims} <- Accounts.token_sign_in(email, password) do
      conn |> render(:show, %{token: token, code: @response_codes.ok})
    else
      _ ->
        conn
        |> put_status(401)
        |> render(:show_error, %{
          error: "wrong credentials supplied",
          code: @response_codes.unauthorized
        })
    end
  end

  def login(conn, _) do
    conn
    |> put_status(400)
    |> render(:show_error, %{
      code: @response_codes.invalid,
      error: "Invalid input, identity and password is required"
    })
  end

  def logout(conn, _) do
    token = get_token(conn)

    case revoke_token(token) do
      {:ok, %Token{}} ->
        conn
        |> json(%{
          data: %{
            "message" => "logout operation was successful"
          },
          code: @response_codes.ok
        })

      _ ->
        conn
        |> put_status(401)
        |> render(:show_error, %{
          code: @response_codes.unauthorized,
          error: "token is invalid"
        })
    end
  end

  def send_reset_password_mail(conn, %{"identity" => identity}) when is_binary(identity) do
    with {:ok, %User{} = user} <- Accounts.get_by_email_or_username(identity),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user, %{}, ttl: {5, :minutes}) do
      if is_nil(user.password_hash) do
        conn
        |> put_status(403)
        |> render(:show_error, %{
          code: @response_codes.forbidden,
          error: "you were authenticated through an IDP and as such cannot update password"
        })
      else
        email = DiaryAPI.ResetPasswordMail.reset_user_password(user, token)
        DiaryAPI.Mailer.deliver(email)

        conn
        |> json(%{
          code: @response_codes.ok,
          message:
            "An email with a link to reset your password will be sent to you if you have an account",
          token: token
        })
      end
    else
      {:error, "Login error."} ->
        conn
        |> put_status(404)
        |> render(:show_error, %{
          error: "user was not found",
          code: @response_codes.not_found
        })

      _ ->
        conn
        |> put_status(500)
        |> render(:show_error, %{
          error: "An error occured",
          code: @response_codes.server_error
        })
    end
  end

  def send_reset_password_mail(conn, _user_params) do
    conn
    |> put_status(400)
    |> render(:show_error, %{
      code: @response_codes.invalid,
      error:
        "Invalid input, the payload must have identity key and its value can either be your email or your username"
    })
  end

  def update_password(conn, %{"password" => password}) when is_binary(password) do
    user = Guardian.Plug.current_resource(conn)

    case Accounts.update_password(user.email, password) do
      {:ok, _user_struct} ->
        conn
        |> put_status(200)
        |> json(%{
          data: %{
            "message" => "Password update was successful"
          },
          code: @response_codes.ok
        })

      {:error, %Changeset{} = changeset_error} ->
        conn
        |> put_status(400)
        |> render(:show_error, %{
          error: translate_errors(changeset_error),
          code: @response_codes.invalid
        })

      _ ->
        conn
        |> put_status(500)
        |> render(:show_error, %{
          error: "Internal server error",
          code: @response_codes.server_error
        })
    end
  end

  def update_password(conn, _user_params) do
    conn
    |> put_status(400)
    |> render(:show_error, %{
      error: "Password is required",
      code: @response_codes.invalid
    })
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
end
