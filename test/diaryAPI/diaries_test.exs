defmodule DiaryAPI.DiariesTest do
  use DiaryAPI.DataCase

  alias DiaryAPI.Diaries

  describe "diaries" do
    alias DiaryAPI.Diaries.Diary

    import DiaryAPI.DiariesFixtures

    @invalid_attrs %{name: nil, description: nil, image: nil}

    test "list_diaries/0 returns all diaries" do
      diary = diary_fixture()
      assert Diaries.list_diaries() == [diary]
    end

    test "get_diary!/1 returns the diary with given id" do
      diary = diary_fixture()
      assert Diaries.get_diary!(diary.id) == diary
    end

    test "create_diary/1 with valid data creates a diary" do
      valid_attrs = %{name: "some name", description: "some description", image: "some image"}

      assert {:ok, %Diary{} = diary} = Diaries.create_diary(valid_attrs)
      assert diary.name == "some name"
      assert diary.description == "some description"
      assert diary.image == "some image"
    end

    test "create_diary/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Diaries.create_diary(@invalid_attrs)
    end

    test "update_diary/2 with valid data updates the diary" do
      diary = diary_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", image: "some updated image"}

      assert {:ok, %Diary{} = diary} = Diaries.update_diary(diary, update_attrs)
      assert diary.name == "some updated name"
      assert diary.description == "some updated description"
      assert diary.image == "some updated image"
    end

    test "update_diary/2 with invalid data returns error changeset" do
      diary = diary_fixture()
      assert {:error, %Ecto.Changeset{}} = Diaries.update_diary(diary, @invalid_attrs)
      assert diary == Diaries.get_diary!(diary.id)
    end

    test "delete_diary/1 deletes the diary" do
      diary = diary_fixture()
      assert {:ok, %Diary{}} = Diaries.delete_diary(diary)
      assert_raise Ecto.NoResultsError, fn -> Diaries.get_diary!(diary.id) end
    end

    test "change_diary/1 returns a diary changeset" do
      diary = diary_fixture()
      assert %Ecto.Changeset{} = Diaries.change_diary(diary)
    end
  end
end
