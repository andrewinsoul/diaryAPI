defmodule DiaryAPI.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DiaryAPIWeb.Telemetry,
      DiaryAPI.Repo,
      {DNSCluster, query: Application.get_env(:diaryAPI, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DiaryAPI.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: DiaryAPI.Finch},
      # Start a worker by calling: DiaryAPI.Worker.start_link(arg)
      # {DiaryAPI.Worker, arg},
      # Start to serve requests, typically the last entry
      DiaryAPIWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DiaryAPI.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DiaryAPIWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
