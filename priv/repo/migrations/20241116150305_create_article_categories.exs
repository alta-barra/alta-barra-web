defmodule Altabarra.Repo.Migrations.CreateArticleCategories do
  use Ecto.Migration

  def change do
    create table(:article_categories) do
      add :article_id, references(:articles, on_delete: :nothing)
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:article_categories, [:article_id])
    create index(:article_categories, [:category_id])
  end
end
