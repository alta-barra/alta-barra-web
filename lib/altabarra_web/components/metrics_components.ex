defmodule AltabarraWeb.AnalyticsComponents do
  use Phoenix.Component

  def metric_box(assigns) do
    ~H"""
    <div class="metric-box p-6 bg-white shadow-md rounded-lg mb-6">
      <h2 class="text-xl font-semibold"><%= @title %></h2>
      <p class="text-2xl font-bold"><%= @value %></p>
    </div>
    """
  end

  def render_table(assigns) do
    ~H"""
    <div class="table-container p-6 bg-white shadow-md rounded-lg mb-6">
      <h2 class="text-xl font-semibold mb-4"><%= @title %></h2>
      <table class="min-w-full bg-white border border-gray-200">
        <thead>
          <tr class="bg-gray-100">
            <%= for col <- @headers do %>
              <th class="text-left py-2 px-4 border-b font-medium text-gray-600"><%= col %></th>
            <% end %>
          </tr>
        </thead>
        <tbody>
          <%= for row <- @rows do %>
            <tr class="border-b hover:bg-gray-50">
              <%= for cell <- row do %>
                <td class="py-2 px-4"><%= cell %></td>
              <% end %>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
