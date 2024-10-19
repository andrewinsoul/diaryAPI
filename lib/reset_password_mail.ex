defmodule DiaryAPI.ResetPasswordMail do
  alias DiaryAPI.Accounts.User

  use Phoenix.Swoosh,
    template_root: "lib/diaryAPI_web/templates/emails",
    template_path: "reset_password"

  import Swoosh.Email
  # import DiaryAPI.Mailer, only: [premail: 1]

  @spec reset_user_password(
          %User{},
          String.t()
        ) :: any()
  def reset_user_password(%User{} = user, token) do
    new()
    |> from({"Diary One", "andrewinsoul@gmail.com"})
    |> subject("Reset Password Instructions")
    |> to({"#{user.firstname} #{user.lastname}", user.email})
    |> render_body("reset_password.html", %{
      name: "#{user.firstname} #{user.lastname}",
      token: token
    })
    # |> premail()
  end
end
