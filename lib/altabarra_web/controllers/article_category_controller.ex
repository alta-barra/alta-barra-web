defmodule AltabarraWeb.ArticleCategoryController do
  use AltabarraWeb, :controller

  alias Altabarra.Content
  alias Altabarra.Content.ArticleCategory

  def index(conn, _params) do
    article_categories = Content.list_article_categories()
    render(conn, :index, article_categories: article_categories)
  end

  def new(conn, _params) do
    changeset = Content.change_article_category(%ArticleCategory{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"article_category" => article_category_params}) do
    case Content.create_article_category(article_category_params) do
      {:ok, article_category} ->
        conn
        |> put_flash(:info, "Article category created successfully.")
        |> redirect(to: ~p"/article_categories/#{article_category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    article_category = Content.get_article_category!(id)
    render(conn, :show, article_category: article_category)
  end

  def edit(conn, %{"id" => id}) do
    article_category = Content.get_article_category!(id)
    changeset = Content.change_article_category(article_category)
    render(conn, :edit, article_category: article_category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "article_category" => article_category_params}) do
    article_category = Content.get_article_category!(id)

    case Content.update_article_category(article_category, article_category_params) do
      {:ok, article_category} ->
        conn
        |> put_flash(:info, "Article category updated successfully.")
        |> redirect(to: ~p"/article_categories/#{article_category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, article_category: article_category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    article_category = Content.get_article_category!(id)
    {:ok, _article_category} = Content.delete_article_category(article_category)

    conn
    |> put_flash(:info, "Article category deleted successfully.")
    |> redirect(to: ~p"/article_categories")
  end
end
