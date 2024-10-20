defmodule DiaryAPI.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias DiaryAPI.Repo

  alias DiaryAPI.Accounts.User
  alias DiaryAPI.Guardian

  import Bcrypt, only: [verify_pass: 2, no_user_verify: 0, hash_pwd_salt: 1]

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  def get_by_email_or_username(identity) when is_binary(identity) do
    query =
      from u in User,
        where: u.email == ^identity or u.username == ^identity

    case Repo.one(query) do
      nil ->
        no_user_verify()
        {:error, "Login error."}

      user ->
        {:ok, user}
    end
  end

  def update_password(identity, password) when is_binary(identity) and is_binary(password) do
    case get_by_email_or_username(identity) do
      {:ok, user} ->
        new_user_info = Ecto.Changeset.change(user, password_hash: hash_pwd_salt(password))
        Repo.update(new_user_info)
    end
  end

  defp verify_password(password, user_data) when is_binary(password) do
    if verify_pass(password, user_data.password_hash) do
      {:ok, user_data}
    else
      {:error, :invalid_password}
    end
  end

  defp email_password_auth(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_by_email_or_username(email),
         do: verify_password(password, user)
  end

  def token_sign_in(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        Guardian.encode_and_sign(user)

      _ ->
        {:error, :unauthorized}
    end
  end

  def findOrCreate(user_data) do
    %{
      email: email,
      username: username
    } = user_data

    query =
      from u in User,
        where: u.email == ^email or u.username == ^username

    data_query_result = Repo.one(query)

    if data_query_result == nil do
      user_data_changeset = create_user(user_data)
      Guardian.encode_and_sign(user_data_changeset)
    else
      if data_query_result.password == nil do
        {:code, "METHOD NOT ALLOWED", message: "account cannot authenticate with OAUTH"}
      else
        user_info = Repo.get_by(User, email: email)
        Guardian.encode_and_sign(user_info)
      end
    end
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
