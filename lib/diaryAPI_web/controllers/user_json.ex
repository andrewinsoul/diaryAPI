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
  def show(%{user: user}), do: success_resp(%{data: data(user)}, "CREATED")

  def show(%{token: token, code: code}), do: success_resp(%{token: token}, code)

  defp success_resp(data, code) do
    Map.put_new(%{code: nil, success: true}, :data, data)
    |> Map.replace(:code, code)
  end

  defp failure_resp(error, code) do
    Map.put_new(%{code: nil, success: false}, :errors, error)
    |> Map.replace(:code, code)
  end

  def show_error(%{error: error, code: code}), do: failure_resp(error, code)

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
