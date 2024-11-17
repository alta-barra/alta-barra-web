defmodule Altabarra.Repo.Migrations.CreateArticleTags do
  use Ecto.Migration

  def change do
    create table(:article_tags) do
      add :article_id, references(:articles, on_delete: :nothing)
      add :tag_id, references(:tags, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:article_tags, [:article_id])
    create index(:article_tags, [:tag_id])
  end
end
