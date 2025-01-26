defmodule AltabarraWeb.CategoryController do
  use AltabarraWeb, :controller

  alias Altabarra.Repo
  alias Altabarra.Content
  alias Altabarra.Content.Category

  def index(conn, _params) do
    categories = Content.list_categories()
    render(conn, :index, categories: categories)
  end

  def new(conn, _params) do
    categories = Content.list_categories()
    changeset = Content.change_category(%Category{})
    render(conn, :new, changeset: changeset, categories: categories)
  end

  def create(conn, %{"category" => category_params}) do
    categories = Content.list_categories()

    case Content.create_category(category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: ~p"/categories/#{category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset, categories: categories)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Content.get_category!(id) |> Repo.preload(:parent)
    render(conn, :show, category: category)
  end

  def edit(conn, %{"id" => id}) do
    categories = Content.list_categories()
    category = Content.get_category!(id)
    changeset = Content.change_category(category)
    render(conn, :edit, category: category, changeset: changeset, categories: categories)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Content.get_category!(id)

    case Content.update_category(category, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: ~p"/categories/#{category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Content.list_categories()
        render(conn, :edit, category: category, changeset: changeset, categories: categories)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Content.get_category!(id)
    {:ok, _category} = Content.delete_category(category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: ~p"/categories")
  end
end
