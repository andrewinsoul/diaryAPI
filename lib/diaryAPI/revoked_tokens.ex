defmodule DiaryAPI.RevokedTokens do
  @moduledoc """
  The Token context.
  """
  import Ecto.Query, warn: false
  alias DiaryAPI.Repo

  alias DiaryAPI.RevokedToken.Token

  @doc """
  Inserts jti of a revoked token.

  ## Examples

      iex> create_revoked_token(%{field: value})
      {:ok, %Token{}}

      iex> create_revoked_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_revoked_token(attrs \\ %{}) do
    %Token{}
    |> Token.changeset(attrs)
    |> Repo.insert()
  end

  def fetch_revoked_token(jti) do
    Token |> where([token], token.jti == ^jti) |> Repo.one()
  end
end
