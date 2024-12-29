defmodule AltabarraWeb.BlogController do
  use AltabarraWeb, :controller

  alias Altabarra.Content

  def index(conn, _) do
    articles = Content.list_articles()
    render(conn, :index, articles: articles)
  end

  def show(conn, %{"id" => slug}) do
    article = Content.get_article_by_slug!(slug)
    render(conn, :show, article: article)
  end
end
