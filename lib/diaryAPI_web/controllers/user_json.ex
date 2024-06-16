defmodule DiaryAPIWeb.UserJSON do
  alias DiaryAPI.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      password_hash: user.password_hash,
      firstname: user.firstname,
      lastname: user.lastname,
      username: user.username
    }
  end
end
