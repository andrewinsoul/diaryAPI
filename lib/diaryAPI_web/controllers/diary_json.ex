defmodule DiaryAPIWeb.DiaryJSON do
  alias DiaryAPI.Diaries.Diary
  alias DiaryAPIWeb.ParentJSON
  alias DiaryAPIWeb.ResponseCodes

  @response_codes ResponseCodes.response_codes_mapper()

  @doc """
  Renders a list of diaries.
  """
  def index(%{diaries: diaries}) do
    %{code: @response_codes.ok, data: for(diary <- diaries, do: data(diary))}
  end

  @doc """
  Renders a single diary.
  """
  def show(%{diary: diary}, code \\ @response_codes.ok) do
    %{data: data(diary), code: code}
  end

  # def create(%{diary: diary}) do
  #   %{code: @response_codes.created, data: data(diary)}
  # end

  # def update(%{diary: diary}) do

  # end

  def delete() do
    %{code: @response_codes.deleted, data: %{message: "Diary was deleted successfully"}}
  end

  def show_error(%{error: error, code: code}),
    do: ParentJSON.show_error(%{error: error, code: code})

  defp data(%Diary{} = diary) do
    %{
      id: diary.diary_id,
      name: diary.name,
      image: diary.image,
      description: diary.description
    }
  end
end
