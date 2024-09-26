defmodule AltabarraWeb.PageController do
  use AltabarraWeb, :controller

  def home(conn, _), do: render(conn, :home, layout: false)
  def contact(conn, _), do: render(conn, :contact)
end
