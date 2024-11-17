defmodule Altabarra.Content.ArticleCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "article_categories" do

    field :article_id, :id
    field :category_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article_category, attrs) do
    article_category
    |> cast(attrs, [])
    |> validate_required([])
  end
end
