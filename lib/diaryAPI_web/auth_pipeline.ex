defmodule DiaryAPI.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :DiaryAPI,
  module: DiaryAPI.Guardian,
  error_handler: DiaryAPI.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
