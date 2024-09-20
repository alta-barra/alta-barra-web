defmodule AltabarraWeb.HealthcheckController do
  @moduledoc false

  use AltabarraWeb, :controller


  def status(conn, _params) do
    services_status = %{webapp: "normal"}

    json(conn, services_status)
  end
end
