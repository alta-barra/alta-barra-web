defmodule Altabarra.Repo.Migrations.UpdateCategoriesTableContraints do
  use Ecto.Migration

  def up do
    execute "DELETE FROM categories WHERE name IS NULL"

    alter table(:categories) do
      modify :name, :string, null: false
      remove :slug
    end
  end

  def down do
    alter table(:categories) do
      add :slug, :string, null: true
      modify :name, :string, null: true
    end
  end
end

