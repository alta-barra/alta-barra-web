defmodule Altabarra.Stac.Item do
  @moduledoc """
  Defines a STAC Item.
  """
  @derive Jason.Encoder
  defstruct type: "Feature",
            stac_version: "1.0.0",
            stac_extensions: [],
            id: nil,
            geometry: nil,
            bbox: [],
            properties: %{},
            links: [],
            assets: %{},
            collection: nil
end
