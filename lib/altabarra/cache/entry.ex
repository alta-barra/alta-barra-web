defmodule Altabarra.Cache.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cache_entries" do
    field :namespace, :string
    field :key, :string
    field :value, :string
    field :inserted_at, :utc_datetime
    field :updated_at, :utc_datetime
  end

  def changeset(cache, attrs) do
    cache
    |> cast(attrs, [:namespace, :key, :value])
    |> validate_required([:namespace, :key, :value])
    |> unique_constraint([:namespace, :key], name: :cache_entries_namespace_key_index)
  end
end
