defmodule AltabarraWeb.ArticleTagHTML do
  use AltabarraWeb, :html

  embed_templates "article_tag_html/*"

  @doc """
  Renders a article_tag form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def article_tag_form(assigns)
end
