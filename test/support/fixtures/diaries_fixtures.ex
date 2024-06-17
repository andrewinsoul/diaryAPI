defmodule DiaryAPI.DiariesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DiaryAPI.Diaries` context.
  """

  @doc """
  Generate a diary.
  """
  def diary_fixture(attrs \\ %{}) do
    {:ok, diary} =
      attrs
      |> Enum.into(%{
        description: "some description",
        image: "some image",
        name: "some name"
      })
      |> DiaryAPI.Diaries.create_diary()

    diary
  end
end
