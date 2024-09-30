defmodule AltabarraWeb.PageViewController do
  use AltabarraWeb, :controller

  alias Altabarra.Analytics
  alias Altabarra.Analytics.PageView

  def index(conn, _params) do
    page_views = Analytics.list_page_views()
    render(conn, :index, page_views: page_views)
  end

  def new(conn, _params) do
    changeset = Analytics.change_page_view(%PageView{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"page_view" => page_view_params}) do
    case Analytics.create_page_view(page_view_params) do
      {:ok, page_view} ->
        conn
        |> put_flash(:info, "Page view created successfully.")
        |> redirect(to: ~p"/page_views/#{page_view}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    page_view = Analytics.get_page_view!(id)
    render(conn, :show, page_view: page_view)
  end

  def edit(conn, %{"id" => id}) do
    page_view = Analytics.get_page_view!(id)
    changeset = Analytics.change_page_view(page_view)
    render(conn, :edit, page_view: page_view, changeset: changeset)
  end

  def update(conn, %{"id" => id, "page_view" => page_view_params}) do
    page_view = Analytics.get_page_view!(id)

    case Analytics.update_page_view(page_view, page_view_params) do
      {:ok, page_view} ->
        conn
        |> put_flash(:info, "Page view updated successfully.")
        |> redirect(to: ~p"/page_views/#{page_view}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, page_view: page_view, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    page_view = Analytics.get_page_view!(id)
    {:ok, _page_view} = Analytics.delete_page_view(page_view)

    conn
    |> put_flash(:info, "Page view deleted successfully.")
    |> redirect(to: ~p"/page_views")
  end
end
