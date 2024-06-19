defmodule DiaryAPIWeb.EntryController do
  use DiaryAPIWeb, :controller

  alias DiaryAPI.Entries
  alias DiaryAPI.Entries.Entry

  action_fallback DiaryAPIWeb.FallbackController

  def index(conn, _params) do
    entries = Entries.list_entries()
    render(conn, :index, entries: entries)
  end

  # def create(conn, %{"entry" => entry_params}) do
  #   with {:ok, %Entry{} = entry} <- Entries.create_entry(entry_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", ~p"/api/entries/#{entry}")
  #     |> render(:show, entry: entry)
  #   end
  # end

  def show(conn, %{"id" => id}) do
    entry = Entries.get_entry!(id)
    render(conn, :show, entry: entry)
  end

  def update(conn, %{"id" => id, "entry" => entry_params}) do
    entry = Entries.get_entry!(id)

    with {:ok, %Entry{} = entry} <- Entries.update_entry(entry, entry_params) do
      render(conn, :show, entry: entry)
    end
  end

  def delete(conn, %{"id" => id}) do
    entry = Entries.get_entry!(id)

    with {:ok, %Entry{}} <- Entries.delete_entry(entry) do
      send_resp(conn, :no_content, "")
    end
  end
end
