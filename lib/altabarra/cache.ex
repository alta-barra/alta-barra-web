defmodule Altabarra.Cache do
  @moduledoc """
  Defines a genserver that acts as a key-value pair cache that is backed by the database.
  """
  use GenServer
  import Ecto.Query
  alias Altabarra.Repo
  alias Altabarra.Cache.Entry

  # Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get(namespace, key) do
    GenServer.call(__MODULE__, {:get, namespace, key})
  end

  def put(namespace, key, value) do
    GenServer.call(__MODULE__, {:put, namespace, key, value})
  end

  def delete(namespace, key) do
    GenServer.call(__MODULE__, {:delete, namespace, key})
  end

  def clear(namespace) do
    GenServer.call(__MODULE__, {:clear, namespace})
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    schedule_cleanup()
    {:ok, %{}}
  end

  @impl true
  def handle_call({:get, namespace, key}, _from, state) do
    result =
      case Repo.get_by(Entry, namespace: namespace, key: key) do
        nil -> nil
        entry -> entry.value
      end

    {:reply, result, state}
  end

  @impl true
  def handle_call({:put, namespace, key, value}, _from, state) do
    result =
      %Entry{}
      |> Entry.changeset(%{namespace: namespace, key: key, value: value})
      |> Repo.insert(
        on_conflict: [set: [value: value, updated_at: DateTime.utc_now()]],
        conflict_target: [:namespace, :key]
      )

    {:reply, result, state}
  end

  @impl true
  def handle_call({:delete, namespace, key}, _from, state) do
    result =
      case Repo.get_by(Entry, namespace: namespace, key: key) do
        nil -> {:error, :not_found}
        entry -> Repo.delete(entry)
      end

    {:reply, result, state}
  end

  @impl true
  def handle_call({:clear, namespace}, _from, state) do
    {deleted_count, _} =
      from(e in Entry, where: e.namespace == ^namespace)
      |> Repo.delete_all()

    {:reply, {:ok, deleted_count}, state}
  end

  @impl true
  def handle_info(:cleanup, state) do
    delete_old_entries()
    schedule_cleanup()
    {:noreply, state}
  end

  # Private functions

  defp delete_old_entries do
    cutoff_date = DateTime.utc_now() |> DateTime.add(-60 * 24 * 60 * 60, :second)

    from(e in Entry, where: e.updated_at < ^cutoff_date)
    |> Repo.delete_all()
  end

  defp schedule_cleanup do
    # Run once a week
    Process.send_after(self(), :cleanup, 7 * 24 * 60 * 60 * 1000)
  end
end
