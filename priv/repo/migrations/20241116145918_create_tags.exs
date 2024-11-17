defmodule Altabarra.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      add :slug, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
