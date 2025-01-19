defmodule DiaryAPIWeb.UserJSON do
  alias DiaryAPI.Accounts.User
  alias DiaryAPIWeb.ParentJSON

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """

  def show(%{token: token, code: code}), do: ParentJSON.show(%{data: %{token: token}, code: code})

  def oauth_show(%{token: token, redirect_uri: redirect_uri}),
    do: ParentJSON.show(%{data: %{token: token}, code: "OK", redirect_uri: redirect_uri})

  def show_error(%{error: error, code: code}),
    do: ParentJSON.show_error(%{error: error, code: code})

  defp data(%User{} = user) do
    %{
      id: user.user_id,
      email: user.email,
      password_hash: user.password_hash,
      firstname: user.firstname,
      lastname: user.lastname,
      username: user.username
    }
  end
end
