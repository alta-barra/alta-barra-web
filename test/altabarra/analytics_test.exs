defmodule Altabarra.AnalyticsTest do
  use Altabarra.DataCase

  alias Altabarra.Analytics

  describe "page_views" do
    alias Altabarra.Analytics.PageView

    import Altabarra.AnalyticsFixtures

    @invalid_attrs %{timestamp: nil, url: nil, user_agent: nil, ip_address: nil, referer: nil}

    test "list_page_views/0 returns all page_views" do
      page_view = page_view_fixture()
      assert Analytics.list_page_views() == [page_view]
    end

    test "get_page_view!/1 returns the page_view with given id" do
      page_view = page_view_fixture()
      assert Analytics.get_page_view!(page_view.id) == page_view
    end

    test "create_page_view/1 with valid data creates a page_view" do
      valid_attrs = %{timestamp: ~N[2024-09-29 17:39:00], url: "some url", user_agent: "some user_agent", ip_address: "some ip_address", referer: "some referer"}

      assert {:ok, %PageView{} = page_view} = Analytics.create_page_view(valid_attrs)
      assert page_view.timestamp == ~N[2024-09-29 17:39:00]
      assert page_view.url == "some url"
      assert page_view.user_agent == "some user_agent"
      assert page_view.ip_address == "some ip_address"
      assert page_view.referer == "some referer"
    end

    test "create_page_view/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Analytics.create_page_view(@invalid_attrs)
    end

    test "update_page_view/2 with valid data updates the page_view" do
      page_view = page_view_fixture()
      update_attrs = %{timestamp: ~N[2024-09-30 17:39:00], url: "some updated url", user_agent: "some updated user_agent", ip_address: "some updated ip_address", referer: "some updated referer"}

      assert {:ok, %PageView{} = page_view} = Analytics.update_page_view(page_view, update_attrs)
      assert page_view.timestamp == ~N[2024-09-30 17:39:00]
      assert page_view.url == "some updated url"
      assert page_view.user_agent == "some updated user_agent"
      assert page_view.ip_address == "some updated ip_address"
      assert page_view.referer == "some updated referer"
    end

    test "update_page_view/2 with invalid data returns error changeset" do
      page_view = page_view_fixture()
      assert {:error, %Ecto.Changeset{}} = Analytics.update_page_view(page_view, @invalid_attrs)
      assert page_view == Analytics.get_page_view!(page_view.id)
    end

    test "delete_page_view/1 deletes the page_view" do
      page_view = page_view_fixture()
      assert {:ok, %PageView{}} = Analytics.delete_page_view(page_view)
      assert_raise Ecto.NoResultsError, fn -> Analytics.get_page_view!(page_view.id) end
    end

    test "change_page_view/1 returns a page_view changeset" do
      page_view = page_view_fixture()
      assert %Ecto.Changeset{} = Analytics.change_page_view(page_view)
    end
  end
end
