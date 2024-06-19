defmodule DiaryAPIWeb.DiaryJSON do
  alias DiaryAPI.Diaries.Diary

  @doc """
  Renders a list of diaries.
  """
  def index(%{diaries: diaries}) do
    %{data: for(diary <- diaries, do: data(diary))}
  end

  @doc """
  Renders a single diary.
  """
  def show(%{diary: diary}) do
    %{data: data(diary)}
  end

  defp data(%Diary{} = diary) do
    %{
      id: diary.diary_id,
      name: diary.name,
      image: diary.image,
      description: diary.description
    }
  end
end
