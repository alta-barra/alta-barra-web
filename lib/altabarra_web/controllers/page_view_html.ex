defmodule AltabarraWeb.PageViewHTML do
  use AltabarraWeb, :html

  embed_templates "page_view_html/*"

  @doc """
  Renders a page_view form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def page_view_form(assigns)
end
