defmodule AltabarraWeb.FactCheckController do
  use AltabarraWeb, :controller

  alias Altabarra.Content
  alias Altabarra.Content.FactCheck

  def index(conn, _params) do
    fact_checks = Content.list_fact_checks()
    render(conn, :index, fact_checks: fact_checks)
  end

  def new(conn, _params) do
    changeset = Content.change_fact_check(%FactCheck{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"fact_check" => fact_check_params}) do
    case Content.create_fact_check(fact_check_params) do
      {:ok, fact_check} ->
        conn
        |> put_flash(:info, "Fact check created successfully.")
        |> redirect(to: ~p"/fact_checks/#{fact_check}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    fact_check = Content.get_fact_check!(id)
    render(conn, :show, fact_check: fact_check)
  end

  def edit(conn, %{"id" => id}) do
    fact_check = Content.get_fact_check!(id)
    changeset = Content.change_fact_check(fact_check)
    render(conn, :edit, fact_check: fact_check, changeset: changeset)
  end

  def update(conn, %{"id" => id, "fact_check" => fact_check_params}) do
    fact_check = Content.get_fact_check!(id)

    case Content.update_fact_check(fact_check, fact_check_params) do
      {:ok, fact_check} ->
        conn
        |> put_flash(:info, "Fact check updated successfully.")
        |> redirect(to: ~p"/fact_checks/#{fact_check}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, fact_check: fact_check, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    fact_check = Content.get_fact_check!(id)
    {:ok, _fact_check} = Content.delete_fact_check(fact_check)

    conn
    |> put_flash(:info, "Fact check deleted successfully.")
    |> redirect(to: ~p"/fact_checks")
  end
end
