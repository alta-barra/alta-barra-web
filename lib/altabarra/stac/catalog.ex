defmodule Altabarra.Stac.Catalog do
  @moduledoc """
  Defines a STAC Catalog.
  """
  @derive Jason.Encoder
  defstruct type: "Catalog",
            stac_version: "1.0.0",
            id: nil,
            description: nil,
            links: [],
            title: nil,
            stac_extensions: []
end
