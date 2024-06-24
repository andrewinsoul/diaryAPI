defmodule DiaryAPIWeb.EntryJSON do
  alias DiaryAPI.Entries.Entry

  @doc """
  Renders a list of entries.
  """
  def index(%{entries: entries}) do
    %{data: for(entry <- entries, do: data(entry))}
  end

  @doc """
  Renders a single entry.
  """
  def show(%{entry: entry}) do
    %{data: data(entry)}
  end

  defp data(%Entry{} = entry) do
    %{
      id: entry.entry_id,
      title: entry.title,
      image: entry.image,
      content: entry.content,
      is_private: entry.is_private
    }
  end
end
