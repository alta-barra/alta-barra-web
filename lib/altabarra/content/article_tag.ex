defmodule Altabarra.Content.ArticleTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "article_tags" do

    field :article_id, :id
    field :tag_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article_tag, attrs) do
    article_tag
    |> cast(attrs, [])
    |> validate_required([])
  end
end
