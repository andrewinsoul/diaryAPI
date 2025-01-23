import Ecto.Query, only: [where: 3], warn: false

defmodule DiaryAPIWeb.Utils do
  alias DiaryAPI.RevokedToken.Token
  alias DiaryAPI.RevokedTokens
  alias DiaryAPI.Diaries.Diary

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Gettext.dgettext(DiaryAPIWeb.Gettext, "errors", msg, opts)
    end)
  end

  def get_token(conn, auth \\ "authorization") do
    conn
    |> Plug.Conn.get_req_header(auth)
    |> List.first()
    |> String.replace("Bearer ", "")
  end

  def revoke_token(token) do
    {:ok, claims} = DiaryAPI.Guardian.decode_and_verify(token)
    token_jti = claims["jti"]

    case RevokedTokens.fetch_revoked_token(token_jti) do
      nil -> RevokedTokens.create_revoked_token(%{jti: token_jti})
      _ -> {:error, :invalid_token}
    end
  end

  @spec decode_token(binary()) :: {:error, any()} | {:ok, map()}
  def decode_token(token) do
    with {:ok, claims} <- DiaryAPI.Guardian.decode_and_verify(token),
         nil <- RevokedTokens.fetch_revoked_token(claims["jti"]) do
      {:ok, claims}
    else
      {:error, :token_expired} ->
        {:error, :token_expired}

      {:error, :invalid_token} ->
        {:error, :invalid_token}

      %Token{} ->
        {:error, :invalid_token}

      err ->
        err
    end
  end

  @spec filter_out_soft_delete_col(Diary) :: Ecto.Query.t()
  def filter_out_soft_delete_col(query) do
    query |> where([q], is_nil(q.deleted_at))
  end
end
