defmodule DiaryAPI.Mailer do
  use Swoosh.Mailer, otp_app: :diaryAPI
  import Swoosh.Email, only: [html_body: 2, text_body: 2]

  # Inline CSS so it works in all browsers
  def premail(email) do
    html = Premailex.to_inline_css(email.html_body)
    text = Premailex.to_text(email.html_body)

    email
    |> html_body(html)
    |> text_body(text)
  end
end
