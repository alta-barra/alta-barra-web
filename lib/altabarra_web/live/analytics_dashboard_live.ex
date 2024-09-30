defmodule AltabarraWeb.AnalyticsDashboardLive do
  use AltabarraWeb, :live_view

  alias Altabarra.Analytics

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
      recent_visitors: Analytics.get_recent_visitors(10)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Analytics Dashboard</h1>

    <div class="analytics-summary">
      <h2>Total Page Views: <%= @analytics_data.total_views %></h2>
    </div>

    <div class="top-pages">
      <h2>Top 5 Pages</h2>
      <ul>
        <%= for {url, views} <- @analytics_data.top_pages do %>
          <li><%= url %> - <%= views %> views</li>
        <% end %>
      </ul>
    </div>

    <div class="recent-visitors">
      <h2>Recent Visitors</h2>
      <table>
        <thead>
          <tr>
            <th>URL</th>
            <th>IP Address</th>
            <th>User Agent</th>
            <th>Timestamp</th>
          </tr>
        </thead>
        <tbody>
          <%= for visitor <- @analytics_data.recent_visitors do %>
            <tr>
              <td><%= visitor.url %></td>
              <td><%= visitor.ip_address %></td>
              <td><%= visitor.user_agent %></td>
              <td><%= visitor.timestamp %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
