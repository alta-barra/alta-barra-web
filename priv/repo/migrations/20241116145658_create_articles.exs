defmodule Altabarra.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :slug, :string
      add :title, :string
      add :description, :text
      add :content, :text
      add :type, :string
      add :status, :string
      add :published_at, :utc_datetime
      add :featured, :boolean, default: false, null: false
      add :meta_title, :string
      add :meta_description, :text
      add :reading_time, :integer
      add :author_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:articles, [:author_id])
  end
end
