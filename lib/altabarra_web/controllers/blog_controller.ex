defmodule AltabarraWeb.BlogController do
  use AltabarraWeb, :controller

  alias Altabarra.Content
  alias Altabarra.Content.Article

  def index(conn, _), do: render(conn, :index)


  def show(conn, %{"id" => slug}) do
    IO.puts(slug)
    
    article = Content.get_article_by_slug!(slug)
    render(conn, :show, article: article)
  end
end
