defmodule Altabarra.Analytics do
  @moduledoc """
  The Analytics context.
  """

  import Ecto.Query, warn: false
  alias Altabarra.Repo

  alias Altabarra.Accounts.{User, UserToken}
  alias Altabarra.Analytics.{ApiAccess, PageView}

  @doc """
  Returns the list of page_views.

  ## Examples

      iex> list_page_views()
      [%PageView{}, ...]

  """
  def list_page_views do
    Repo.all(PageView)
  end

  @doc """
  Gets a single page_view.

  Raises `Ecto.NoResultsError` if the Page view does not exist.

  ## Examples

      iex> get_page_view!(123)
      %PageView{}

      iex> get_page_view!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page_view!(id), do: Repo.get!(PageView, id)

  @doc """
  Creates a page_view.

  ## Examples

      iex> create_page_view(%{field: value})
      {:ok, %PageView{}}

      iex> create_page_view(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_page_view(attrs \\ %{}) do
    %PageView{}
    |> PageView.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a page_view.

  ## Examples

      iex> update_page_view(page_view, %{field: new_value})
      {:ok, %PageView{}}

      iex> update_page_view(page_view, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_page_view(%PageView{} = page_view, attrs) do
    page_view
    |> PageView.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a page_view.

  ## Examples

      iex> delete_page_view(page_view)
      {:ok, %PageView{}}

      iex> delete_page_view(page_view)
      {:error, %Ecto.Changeset{}}

  """
  def delete_page_view(%PageView{} = page_view) do
    Repo.delete(page_view)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page_view changes.

  ## Examples

      iex> change_page_view(page_view)
      %Ecto.Changeset{data: %PageView{}}

  """
  def change_page_view(%PageView{} = page_view, attrs \\ %{}) do
    PageView.changeset(page_view, attrs)
  end

  defp get_user_agent(conn) do
    case Plug.Conn.get_req_header(conn, "user-agent") do
      [user_agent] -> user_agent
      _ -> nil
    end
  end

  defp get_ip_address(conn) do
    conn
    |> Plug.Conn.get_req_header("x-forwarded-for")
    |> List.first()
    |> case do
      nil -> conn.remote_ip |> :inet.ntoa() |> to_string() |> String.split(~r/,/) |> List.last()
      ip -> ip
    end
  end

  defp get_referrer(conn) do
    case Plug.Conn.get_req_header(conn, "referer") do
      [referrer] -> referrer
      _ -> nil
    end
  end

  def track_page_view(conn) do
    %{
      url: conn.request_path,
      user_agent: get_user_agent(conn),
      ip_address: get_ip_address(conn),
      referrer: get_referrer(conn),
      host: get_forwarded_host(conn),
      timestamp: NaiveDateTime.utc_now()
    }
    |> create_page_view()
  end

  def track_api_access(conn, body \\ nil) do
    start_time = System.monotonic_time(:millisecond)

    # Capture the response
    response = conn.resp_body

    # Calculate the duration
    end_time = System.monotonic_time(:millisecond)
    duration = end_time - start_time

    %{
      endpoint: conn.request_path,
      method: conn.method,
      status_code: conn.status,
      user_agent: get_user_agent(conn),
      ip_address: get_ip_address(conn),
      request_body: body,
      response_body: response,
      timestamp: NaiveDateTime.utc_now(),
      duration: duration
    }
    |> create_api_analytics()
  end

  defp create_api_analytics(attrs) do
    %ApiAccess{}
    |> ApiAccess.changeset(attrs)
    |> Repo.insert()
  end

  def get_total_page_views do
    Repo.aggregate(PageView, :count, :id)
  end

  defp get_forwarded_host(conn) do
    conn
    |> Plug.Conn.get_req_header("x-forwarded-host")
    |> List.first()
  end

  def get_top_pages(limit) do
    PageView
    |> group_by([pv], pv.url)
    |> select([pv], {pv.url, count(pv.id)})
    |> order_by([pv], desc: count(pv.id))
    |> limit(^limit)
    |> Repo.all()
  end

  def get_recent_visitors(limit) do
    PageView
    |> order_by([pv], desc: pv.timestamp)
    |> limit(^limit)
    |> select([pv], %{
      url: pv.url,
      ip_address: pv.ip_address,
      user_agent: pv.user_agent,
      timestamp: pv.timestamp
    })
    |> Repo.all()
  end

  def get_new_users(days) do
    start_date = DateTime.utc_now() |> DateTime.add(-days, :day)

    User
    |> where([u], u.inserted_at >= ^start_date)
    |> select([u], count(u.id))
    |> Repo.one()
  end

  def get_active_users(days) do
    cutoff_time = DateTime.utc_now() |> DateTime.add(-days, :day)

    UserToken
    |> where([t], t.inserted_at >= ^cutoff_time)
    |> select([t], t.user_id)
    |> distinct(true)
    |> Repo.all()
    |> length()
  end

  def get_top_api_endpoints(limit) do
    ApiAccess
    |> group_by([api], api.endpoint)
    |> select([api], {api.endpoint, count(api.id)})
    |> order_by([api], desc: count(api.id))
    |> limit(^limit)
    |> Repo.all()
  end
end
