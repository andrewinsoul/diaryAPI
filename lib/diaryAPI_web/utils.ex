import Ecto.Query, only: [where: 3], warn: false

defmodule DiaryAPIWeb.Utils do
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

  def filter_out_soft_delete_col(query) do
    query |> where([q], is_nil(q.deleted_at))
  end
end
