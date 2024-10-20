defmodule AltabarraWeb.HealthcheckController do
  @moduledoc false

  use AltabarraWeb, :controller

  def status(conn, _params) do
    render(conn, :healthcheck, overall_status: "OK", services_status: [["WebApp", "OK"]])
  end
end
