defmodule Altabarra.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AltabarraWeb.Telemetry,
      Altabarra.Repo,
      {DNSCluster, query: Application.get_env(:altabarra, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Altabarra.PubSub},
      {Finch, name: Altabarra.Finch},
      # In-memory caches
      Supervisor.child_spec({Altabarra.LRUCache, Altabarra.LRUCache.Default}, id: :cache_0),
      Supervisor.child_spec({Altabarra.LRUCache, Altabarra.LRUCache.CMRCollectionCache},
        id: :cache_1
      ),
      AltabarraWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Altabarra.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AltabarraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
