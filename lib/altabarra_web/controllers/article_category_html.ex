defmodule AltabarraWeb.ArticleCategoryHTML do
  use AltabarraWeb, :html

  embed_templates "article_category_html/*"

  @doc """
  Renders a article_category form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def article_category_form(assigns)
end
