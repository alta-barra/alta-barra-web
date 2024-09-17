defmodule Altabarra.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AltabarraWeb.Telemetry,
      Altabarra.Repo,
      {DNSCluster, query: Application.get_env(:altabarra, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Altabarra.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Altabarra.Finch},
      # Start a worker by calling: Altabarra.Worker.start_link(arg)
      # {Altabarra.Worker, arg},
      # Start to serve requests, typically the last entry
      AltabarraWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Altabarra.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AltabarraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
