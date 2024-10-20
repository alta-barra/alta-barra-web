defmodule Altabarra.Repo.Migrations.CreateApiAnalytics do
  use Ecto.Migration

  def change do
    create table(:api_accesses) do
      add :endpoint, :string, null: false
      add :method, :string, null: false
      add :status_code, :integer
      add :user_agent, :string
      add :ip_address, :string
      add :request_body, :text
      add :response_body, :text
      add :timestamp, :naive_datetime, null: false
      add :duration, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:api_accesses, [:endpoint])
    create index(:api_accesses, [:method])
    create index(:api_accesses, [:timestamp])
  end
end
