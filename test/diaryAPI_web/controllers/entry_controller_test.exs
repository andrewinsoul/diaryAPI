defmodule DiaryAPIWeb.EntryControllerTest do
  use DiaryAPIWeb.ConnCase

  import DiaryAPI.EntriesFixtures

  alias DiaryAPI.Entries.Entry

  @create_attrs %{
    title: "some title",
    image: "some image",
    content: "some content",
    is_private: true
  }
  @update_attrs %{
    title: "some updated title",
    image: "some updated image",
    content: "some updated content",
    is_private: false
  }
  @invalid_attrs %{title: nil, image: nil, content: nil, is_private: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all entries", %{conn: conn} do
      conn = get(conn, ~p"/api/entries")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create entry" do
    test "renders entry when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/entries", entry: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/entries/#{id}")

      assert %{
               "id" => ^id,
               "content" => "some content",
               "image" => "some image",
               "is_private" => true,
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/entries", entry: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update entry" do
    setup [:create_entry]

    test "renders entry when data is valid", %{conn: conn, entry: %Entry{id: id} = entry} do
      conn = put(conn, ~p"/api/entries/#{entry}", entry: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/entries/#{id}")

      assert %{
               "id" => ^id,
               "content" => "some updated content",
               "image" => "some updated image",
               "is_private" => false,
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, entry: entry} do
      conn = put(conn, ~p"/api/entries/#{entry}", entry: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete entry" do
    setup [:create_entry]

    test "deletes chosen entry", %{conn: conn, entry: entry} do
      conn = delete(conn, ~p"/api/entries/#{entry}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/entries/#{entry}")
      end
    end
  end

  defp create_entry(_) do
    entry = entry_fixture()
    %{entry: entry}
  end
end
