defmodule DiaryAPI.EntriesTest do
  use DiaryAPI.DataCase

  alias DiaryAPI.Entries

  describe "entries" do
    alias DiaryAPI.Entries.Entry

    import DiaryAPI.EntriesFixtures

    @invalid_attrs %{title: nil, image: nil, content: nil, is_private: nil}

    test "list_entries/0 returns all entries" do
      entry = entry_fixture()
      assert Entries.list_entries() == [entry]
    end

    test "get_entry!/1 returns the entry with given id" do
      entry = entry_fixture()
      assert Entries.get_entry!(entry.id) == entry
    end

    test "create_entry/1 with valid data creates a entry" do
      valid_attrs = %{title: "some title", image: "some image", content: "some content", is_private: true}

      assert {:ok, %Entry{} = entry} = Entries.create_entry(valid_attrs)
      assert entry.title == "some title"
      assert entry.image == "some image"
      assert entry.content == "some content"
      assert entry.is_private == true
    end

    test "create_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Entries.create_entry(@invalid_attrs)
    end

    test "update_entry/2 with valid data updates the entry" do
      entry = entry_fixture()
      update_attrs = %{title: "some updated title", image: "some updated image", content: "some updated content", is_private: false}

      assert {:ok, %Entry{} = entry} = Entries.update_entry(entry, update_attrs)
      assert entry.title == "some updated title"
      assert entry.image == "some updated image"
      assert entry.content == "some updated content"
      assert entry.is_private == false
    end

    test "update_entry/2 with invalid data returns error changeset" do
      entry = entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Entries.update_entry(entry, @invalid_attrs)
      assert entry == Entries.get_entry!(entry.id)
    end

    test "delete_entry/1 deletes the entry" do
      entry = entry_fixture()
      assert {:ok, %Entry{}} = Entries.delete_entry(entry)
      assert_raise Ecto.NoResultsError, fn -> Entries.get_entry!(entry.id) end
    end

    test "change_entry/1 returns a entry changeset" do
      entry = entry_fixture()
      assert %Ecto.Changeset{} = Entries.change_entry(entry)
    end
  end
end
