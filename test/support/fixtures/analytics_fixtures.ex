defmodule Altabarra.AnalyticsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Altabarra.Analytics` context.
  """

  @doc """
  Generate a page_view.
  """
  def page_view_fixture(attrs \\ %{}) do
    {:ok, page_view} =
      attrs
      |> Enum.into(%{
        ip_address: "some ip_address",
        referer: "some referer",
        timestamp: ~N[2024-09-29 17:39:00],
        url: "some url",
        user_agent: "some user_agent"
      })
      |> Altabarra.Analytics.create_page_view()

    page_view
  end
end
