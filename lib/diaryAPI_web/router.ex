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
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:diaryAPI, :dev_routes) do

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
