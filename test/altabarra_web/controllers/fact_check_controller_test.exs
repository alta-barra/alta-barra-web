defmodule AltabarraWeb.FactCheckControllerTest do
  use AltabarraWeb.ConnCase

  import Altabarra.ContentFixtures

  @create_attrs %{status: "some status", source: "some source", notes: "some notes", verified_at: ~U[2024-11-15 14:58:00Z]}
  @update_attrs %{status: "some updated status", source: "some updated source", notes: "some updated notes", verified_at: ~U[2024-11-16 14:58:00Z]}
  @invalid_attrs %{status: nil, source: nil, notes: nil, verified_at: nil}

  describe "index" do
    test "lists all fact_checks", %{conn: conn} do
      conn = get(conn, ~p"/fact_checks")
      assert html_response(conn, 200) =~ "Listing Fact checks"
    end
  end

  describe "new fact_check" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/fact_checks/new")
      assert html_response(conn, 200) =~ "New Fact check"
    end
  end

  describe "create fact_check" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/fact_checks", fact_check: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/fact_checks/#{id}"

      conn = get(conn, ~p"/fact_checks/#{id}")
      assert html_response(conn, 200) =~ "Fact check #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/fact_checks", fact_check: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Fact check"
    end
  end

  describe "edit fact_check" do
    setup [:create_fact_check]

    test "renders form for editing chosen fact_check", %{conn: conn, fact_check: fact_check} do
      conn = get(conn, ~p"/fact_checks/#{fact_check}/edit")
      assert html_response(conn, 200) =~ "Edit Fact check"
    end
  end

  describe "update fact_check" do
    setup [:create_fact_check]

    test "redirects when data is valid", %{conn: conn, fact_check: fact_check} do
      conn = put(conn, ~p"/fact_checks/#{fact_check}", fact_check: @update_attrs)
      assert redirected_to(conn) == ~p"/fact_checks/#{fact_check}"

      conn = get(conn, ~p"/fact_checks/#{fact_check}")
      assert html_response(conn, 200) =~ "some updated status"
    end

    test "renders errors when data is invalid", %{conn: conn, fact_check: fact_check} do
      conn = put(conn, ~p"/fact_checks/#{fact_check}", fact_check: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Fact check"
    end
  end

  describe "delete fact_check" do
    setup [:create_fact_check]

    test "deletes chosen fact_check", %{conn: conn, fact_check: fact_check} do
      conn = delete(conn, ~p"/fact_checks/#{fact_check}")
      assert redirected_to(conn) == ~p"/fact_checks"

      assert_error_sent 404, fn ->
        get(conn, ~p"/fact_checks/#{fact_check}")
      end
    end
  end

  defp create_fact_check(_) do
    fact_check = fact_check_fixture()
    %{fact_check: fact_check}
  end
end
