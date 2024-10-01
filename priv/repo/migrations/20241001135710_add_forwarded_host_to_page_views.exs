defmodule Altabarra.Repo.Migrations.AddForwardedHostToPageViews do
  use Ecto.Migration

  def change do
    alter table(:page_views) do
      add :host, :string
    end
  end
end
