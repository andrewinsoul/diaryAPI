defmodule DiaryAPIWeb.DiaryJSON do
  alias DiaryAPI.Diaries.Diary
  alias DiaryAPIWeb.ParentJSON
  alias DiaryAPIWeb.ResponseCodes

  @response_codes ResponseCodes.response_codes_mapper()

  @doc """
  Renders a list of diaries.
  """
  def index(%{diaries: diaries, limit: limit, page: page, total: total}) do
    has_prev = if String.to_integer(page) > 1, do: true, else: false

    has_next =
      if String.to_integer(page) < ceil(total / String.to_integer(limit)), do: true, else: false

    %{
      code: @response_codes.ok,
      data: for(diary <- diaries, do: data(diary)),
      meta: %{
        limit: limit,
        page: page,
        has_prev: has_prev,
        has_next: has_next,
        total: total
      }
    }
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

  def delete(_) do
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
