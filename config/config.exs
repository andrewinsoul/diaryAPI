# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :diaryAPI,
  ecto_repos: [DiaryAPI.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :diaryAPI, DiaryAPIWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: DiaryAPIWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: DiaryAPI.PubSub,
  live_view: [signing_salt: "GQ1207pD"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :diaryAPI, DiaryAPI.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Filter logs to log to the console
config :phoenix, :filter_parameters, ["password", "secret", "token"]

# configure ueberauth and initialize idps supported by the application
config :ueberauth, Ueberauth,
  providers: [
    # instagram: {Ueberauth.Strategy.Facebook},
    # twitter: {Ueberauth.Strategy.Github},
    google:
      {Ueberauth.Strategy.Google,
       [
         default_scope: "email profile"
       ]}
  ]

# configure tailwind
config :tailwind,
  version: "3.4.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

# Configure guardian
config :diaryAPI, DiaryAPI.Guardian,
  issuer: "diaryAPI",
  secret_key: System.get_env("SECRET_KEY")

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
