defmodule DiaryAPIWeb.Router do
  use DiaryAPIWeb, :router
  alias DiaryAPI.Guardian

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  scope "/auth", DiaryAPIWeb do
    pipe_through :api

    get "/:provider", UserController, :request
    get "/:provider/callback", UserController, :callback
  end

  scope "/api/v1", DiaryAPIWeb do
    pipe_through :api
    post "/register", UserController, :create
    post "/login", UserController, :login
    post "/send/reset_password/code", UserController, :send_reset_password_mail
    get "/diaries", DiaryController, :fetch_diaries
  end

  scope "/api/v1", DiaryAPIWeb do
    pipe_through [:api, :jwt_authenticated]
    put "/update/password", UserController, :update_password
    post "/add/diary", DiaryController, :create
    patch "/update/diary/:id", DiaryController, :update
    delete "/delete/diary/:id", DiaryController, :delete
    get "/my/diaries", DiaryController, :fetch_my_diaries
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:diaryAPI, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
