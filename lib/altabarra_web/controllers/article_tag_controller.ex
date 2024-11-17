defmodule AltabarraWeb.ArticleTagController do
  use AltabarraWeb, :controller

  alias Altabarra.Content
  alias Altabarra.Content.ArticleTag

  def index(conn, _params) do
    article_tags = Content.list_article_tags()
    render(conn, :index, article_tags: article_tags)
  end

  def new(conn, _params) do
    changeset = Content.change_article_tag(%ArticleTag{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"article_tag" => article_tag_params}) do
    case Content.create_article_tag(article_tag_params) do
      {:ok, article_tag} ->
        conn
        |> put_flash(:info, "Article tag created successfully.")
        |> redirect(to: ~p"/article_tags/#{article_tag}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    article_tag = Content.get_article_tag!(id)
    render(conn, :show, article_tag: article_tag)
  end

  def edit(conn, %{"id" => id}) do
    article_tag = Content.get_article_tag!(id)
    changeset = Content.change_article_tag(article_tag)
    render(conn, :edit, article_tag: article_tag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "article_tag" => article_tag_params}) do
    article_tag = Content.get_article_tag!(id)

    case Content.update_article_tag(article_tag, article_tag_params) do
      {:ok, article_tag} ->
        conn
        |> put_flash(:info, "Article tag updated successfully.")
        |> redirect(to: ~p"/article_tags/#{article_tag}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, article_tag: article_tag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    article_tag = Content.get_article_tag!(id)
    {:ok, _article_tag} = Content.delete_article_tag(article_tag)

    conn
    |> put_flash(:info, "Article tag deleted successfully.")
    |> redirect(to: ~p"/article_tags")
  end
end
