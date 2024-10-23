defmodule Altabarra.Stac.Collection do
  @moduledoc """
  Defines a STAC Collection.
  """
  defstruct type: "Collection",
            stac_version: "1.0.0",
            stac_extensions: [],
            id: nil,
            title: nil,
            description: nil,
            extent: %{},
            license: nil,
            keywords: [],
            providers: [],
            summaries: %{},
            links: []
end
