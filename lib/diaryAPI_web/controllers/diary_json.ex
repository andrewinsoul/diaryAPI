defmodule DiaryAPIWeb.DiaryJSON do
  alias DiaryAPI.Diaries.Diary
  alias DiaryAPIWeb.ParentJSON

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

  def show_error(%{error: error, code: code}), do: ParentJSON.show_error(%{error: error, code: code})

  defp data(%Diary{} = diary) do
    %{
      id: diary.diary_id,
      name: diary.name,
      image: diary.image,
      description: diary.description
    }
  end
end
