defmodule Altabarra.LRUCache do
  use GenServer

  @default_max_entries 4096

  @moduledoc """
  A simple in-memory Least Recently Used (LRU) cache implemented as a `GenServer`.

  This cache stores up to a configurable number of entries, with the default being #{@default_max_entries}. When the cache reaches its capacity, it automatically evicts the oldest entry (the least recently used) to make room for new ones.

  ## Usage

  The cache can be started with a unique name, and multiple caches can be created by using different names. The maximum number of entries can be configured at startup.

  ## Example

  Start a cache with the default capacity:

      iex> Altabarra.LRUCache.start_link(:my_cache)

  Store and retrieve values from the cache:

      iex> Altabarra.LRUCache.put(:my_cache, "key1", "value1")
      :ok

      iex> Altabarra.LRUCache.get(:my_cache, "key1")
      "value1"

  Start a cache with a custom capacity:

      iex> Altabarra.LRUCache.start_link(:large_cache, max_entries: 1024)

  ## Options

  - `:max_entries` - Maximum number of entries the cache can hold. Default is #{@default_max_entries}.
  """

  ## API

  def start_link(name, opts \\ []) do
    max_entries = Keyword.get(opts, :max_entries, @default_max_entries)
    GenServer.start_link(__MODULE__, %{max_entries: max_entries}, name: name)
  end

  def get(name, key) do
    GenServer.call(name, {:get, key})
  end

  def put(name, key, value) do
    GenServer.cast(name, {:put, key, value})
  end

  ## Callbacks

  @impl true
  def init(state) do
    {:ok, Map.merge(state, %{cache: %{}, order: []})}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    value = Map.get(state.cache, key)
    {:reply, value, state}
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    new_state =
      state
      |> update_cache(key, value)
      |> enforce_limit()

    {:noreply, new_state}
  end

  ## Internal Functions

  defp update_cache(state, key, value) do
    cache = Map.put(state.cache, key, value)
    order = [key | Enum.reject(state.order, &(&1 == key))]
    %{state | cache: cache, order: order}
  end

  defp enforce_limit(state) do
    if length(state.order) > state.max_entries do
      [oldest | rest] = state.order
      cache = Map.delete(state.cache, oldest)
      %{state | cache: cache, order: rest}
    else
      state
    end
  end
end
