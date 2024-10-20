defmodule Altabarra.Repo.Migrations.CreateCache do
  use Ecto.Migration

  def change do
    create table(:cache_entries) do
      add :namespace, :string, null: false
      add :key, :string, null: false
      add :value, :text, null: false

      timestamps()
    end

    create unique_index(
             :cache_entries,
             [:namespace, :key],
             name: :cache_entries_namespace_key_index
           )
  end
end
