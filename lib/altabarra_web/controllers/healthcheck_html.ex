defmodule AltabarraWeb.HealthcheckHTML do
  @moduledoc """
  This module is invoked by the status endpoint..
  """
  use AltabarraWeb, :html

  embed_templates "page_html/*"
end
