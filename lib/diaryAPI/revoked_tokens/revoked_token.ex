defmodule DiaryAPI.RevokedToken.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "revoked_tokens" do
    field :jti, :binary_id
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:jti])
    |> validate_required([:jti])
  end
end
