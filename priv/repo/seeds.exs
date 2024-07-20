# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     DiaryAPI.Repo.insert!(%DiaryAPI.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

schema = DiaryAPI.Accounts.User
path_from_schema = to_string(schema) |> String.replace("Elixir", "") |> String.replace(".", "/")
IO.puts("ignore >>>>>>> /lib#{path_from_schema}")
{:ok, file_contents} = File.read("./lib#{path_from_schema}.ex")
# ans1 = String.c
find_required_fields = String.slice(file_contents, "cast(attrs,")
IO.puts(find_required_fields)
{position, length} = file_contents |> :binary.match("cast(attrs,")

IO.puts(position)
IO.puts(length)
