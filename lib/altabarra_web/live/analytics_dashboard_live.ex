defmodule AltabarraWeb.AnalyticsDashboardLive do
  use AltabarraWeb, :live_view

  alias Altabarra.Analytics
  alias AltabarraWeb.AnalyticsComponents

  @refresh_interval_ms 15_000

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(@refresh_interval_ms, self(), :refresh)
    end

    {:ok, assign(socket, analytics_data: fetch_analytics_data())}
  end

  @impl true
  def handle_info(:refresh, socket) do
    {:noreply, assign(socket, analytics_data: fetch_analytics_data())}
  end

  defp fetch_analytics_data do
    %{
      total_views: Analytics.get_total_page_views(),
      top_pages: Analytics.get_top_pages(5),
      recent_visitors: Analytics.get_recent_visitors(10),
      new_users: Analytics.get_new_users(7),
      active_users: Analytics.get_active_users(7)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="font-bold text-3xl mb-6">Analytics Dashboard</h1>
    <!-- Modular Metric Boxes -->
    <AnalyticsComponents.metric_box title="Total Page Views" value={@analytics_data.total_views} />
    <AnalyticsComponents.metric_box title="Active Users" value={@analytics_data.active_users} />
    <AnalyticsComponents.metric_box title="New Users" value={@analytics_data.new_users} />
    <!-- Top Pages Table -->
    <AnalyticsComponents.render_table
      title="Top 5 Pages"
      headers={["URL", "Views"]}
      rows={Enum.map(@analytics_data.top_pages, fn {url, views} -> [url, views] end)}
    />
    <!-- Recent Visitors Table -->
    <AnalyticsComponents.render_table
      title="Recent Visitors"
      headers={["URL", "IP Address", "User Agent", "Timestamp"]}
      rows={
        Enum.map(@analytics_data.recent_visitors, fn visitor ->
          [visitor.url, visitor.ip_address, visitor.user_agent, visitor.timestamp]
        end)
      }
    />
    <!-- Accounts Activity Table -->
    <!-- <AnalyticsComponents.render_table
      title="Recent Account Activity"
      headers={["Account ID", "Action", "Timestamp"]}
      rows={
        Enum.map(@analytics_data.account_activity, fn activity ->
          [activity.account_id, activity.action, activity.timestamp]
        end)
      }
    /> -->
    """
  end
end
