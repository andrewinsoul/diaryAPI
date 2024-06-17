defmodule DiaryAPI.EntriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DiaryAPI.Entries` context.
  """

  @doc """
  Generate a entry.
  """
  def entry_fixture(attrs \\ %{}) do
    {:ok, entry} =
      attrs
      |> Enum.into(%{
        content: "some content",
        image: "some image",
        is_private: true,
        title: "some title"
      })
      |> DiaryAPI.Entries.create_entry()

    entry
  end
end
