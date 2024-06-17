defmodule DiaryAPIWeb.DiaryControllerTest do
  use DiaryAPIWeb.ConnCase

  import DiaryAPI.DiariesFixtures

  alias DiaryAPI.Diaries.Diary

  @create_attrs %{
    name: "some name",
    description: "some description",
    image: "some image"
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    image: "some updated image"
  }
  @invalid_attrs %{name: nil, description: nil, image: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all diaries", %{conn: conn} do
      conn = get(conn, ~p"/api/diaries")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create diary" do
    test "renders diary when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/diaries", diary: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/diaries/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "image" => "some image",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/diaries", diary: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update diary" do
    setup [:create_diary]

    test "renders diary when data is valid", %{conn: conn, diary: %Diary{id: id} = diary} do
      conn = put(conn, ~p"/api/diaries/#{diary}", diary: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/diaries/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "image" => "some updated image",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, diary: diary} do
      conn = put(conn, ~p"/api/diaries/#{diary}", diary: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete diary" do
    setup [:create_diary]

    test "deletes chosen diary", %{conn: conn, diary: diary} do
      conn = delete(conn, ~p"/api/diaries/#{diary}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/diaries/#{diary}")
      end
    end
  end

  defp create_diary(_) do
    diary = diary_fixture()
    %{diary: diary}
  end
end
