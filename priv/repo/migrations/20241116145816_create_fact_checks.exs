defmodule Altabarra.Repo.Migrations.CreateFactChecks do
  use Ecto.Migration

  def change do
    create table(:fact_checks) do
      add :source, :string
      add :status, :string
      add :notes, :text
      add :verified_at, :utc_datetime
      add :checker_id, references(:users, on_delete: :nothing)
      add :article_id, references(:articles, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:fact_checks, [:checker_id])
    create index(:fact_checks, [:article_id])
  end
end
