defmodule AltabarraWeb.FactCheckHTML do
  use AltabarraWeb, :html

  embed_templates "fact_check_html/*"

  @doc """
  Renders a fact_check form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def fact_check_form(assigns)
end
