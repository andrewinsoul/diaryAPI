defmodule DiaryAPI.Repo do
  use Ecto.Repo,
    otp_app: :diaryAPI,
    adapter: Ecto.Adapters.Postgres
end
