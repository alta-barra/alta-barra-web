defmodule AltabarraWeb.ArticleHTML do
  use AltabarraWeb, :html

  import AltabarraWeb.ArticleFormHelpers

  embed_templates "article_html/*"

  @doc """
  Renders a article form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def article_form(assigns)
end
