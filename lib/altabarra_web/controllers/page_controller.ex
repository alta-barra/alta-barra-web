defmodule AltabarraWeb.PageController do
  use AltabarraWeb, :controller

  def home(conn, _), do: render(conn, :home, layout: false)

  def contact(conn, _), do: render(conn, :contact)

  def services(conn, _), do: render(conn, :services)

  def apis(conn, _), do: render(conn, :apis)
end
