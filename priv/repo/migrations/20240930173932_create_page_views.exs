defmodule Altabarra.Repo.Migrations.CreatePageViews do
  use Ecto.Migration

  def change do
    create table(:page_views) do
      add :url, :string, null: false
      add :user_agent, :string
      add :ip_address, :string
      add :referer, :string
      add :timestamp, :naive_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:page_views, [:url])
    create index(:page_views, [:timestamp])
  end
end
