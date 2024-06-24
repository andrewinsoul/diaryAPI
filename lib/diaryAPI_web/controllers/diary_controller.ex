defmodule DiaryAPIWeb.DiaryController do
  use DiaryAPIWeb, :controller

  alias DiaryAPI.Diaries
  alias DiaryAPI.Diaries.Diary

  action_fallback DiaryAPIWeb.FallbackController

  def index(conn, _params) do
    diaries = Diaries.list_diaries()
    render(conn, :index, diaries: diaries)
  end

  def show(conn, %{"id" => id}) do
    diary = Diaries.get_diary!(id)
    render(conn, :show, diary: diary)
  end

  def update(conn, %{"id" => id, "diary" => diary_params}) do
    diary = Diaries.get_diary!(id)

    with {:ok, %Diary{} = diary} <- Diaries.update_diary(diary, diary_params) do
      render(conn, :show, diary: diary)
    end
  end

  def delete(conn, %{"id" => id}) do
    diary = Diaries.get_diary!(id)

    with {:ok, %Diary{}} <- Diaries.delete_diary(diary) do
      send_resp(conn, :no_content, "")
    end
  end
end
