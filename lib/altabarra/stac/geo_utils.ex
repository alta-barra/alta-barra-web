defmodule Altabarra.Stac.GeoUtils do
  @moduledoc """
  BBOX in STAC is defined as [west, south, east, north]

  The first coordinate (west) is the minimum longitude.
  The second coordinate (south) is the minimum latitude.
  The third coordinate (east) is the maximum longitude.
  The fourth coordinate (north) is the maximum latitude.

  CMR JSON format provides coordinates in {lat, lon} order, but STAC specification requires coordinates in {lon, lat} order. This reversal ensures compatibility when converting between formats.

  All conversions in this module are assumed to convert from CMR json data to STAC.
  """
  @earth_radius_meters 111_320
  @bbox_default_meters 10

  @min_longitude -180
  @min_latitude -90
  @max_longitude 180
  @max_latitude 90

  @doc """
  Converts CMR spatial data to STAC bounding box format.

  ## Parameters
  - granule|collection: A CMR result containing one of the following geometry types:
    - %{"points" => points} - List of point coordinates
    - %{"lines" => lines} - List of line coordinates
    - %{"boxes" => boxes} - List of box coordinates
    - %{"polygons" => polygons} - List of polygon coordinates

  ## Returns
  - `[west, south, east, north]` - A list of 4 floats representing the bounding box coordinates where:
    - west: Minimum longitude (x)
    - south: Minimum latitude (y)
    - east: Maximum longitude (x)
    - north: Maximum latitude (y)
  - `nil` - If the input map doesn't contain any of the supported geometry types

  ## Examples

      iex> Altabarra.Stac.GeoUtils.spatial_to_bbox(%{"points" => ["0.0 100.0", "-36.7 18.33"]})
      [18.33, -36.7, 100.0, 0.0]

      iex> Altabarra.Stac.GeoUtils.spatial_to_bbox(%{"boxes" => ["0.0 100.0 1.0 105.0"]})
      [100.0, 0.0, 105.0, 1.0]

      iex> Altabarra.Stac.GeoUtils.spatial_to_bbox(%{"polygons" => [["16.6 -180 16.6 180 61.5 180 61.5 -180 16.6 -180"]]})
      [-180.0, 16.6, 180.0, 61.5]

      iex> Altabarra.Stac.GeoUtils.spatial_to_bbox(%{"invalid" => []})
      nil

  ## Note
  The returned bounding box follows the STAC specification format:
  https://github.com/radiantearth/stac-spec/blob/master/collection-spec/collection-spec.md#spatial-extent-object
  """
  def spatial_to_bbox(%{"points" => points}), do: points |> to_bbox()
  def spatial_to_bbox(%{"lines" => lines}), do: lines |> to_bbox()
  def spatial_to_bbox(%{"boxes" => boxes}), do: boxes |> to_bbox()

  def spatial_to_bbox(%{"polygons" => polygons}) do
    polygons
    # outer ring only
    |> Enum.map(&List.first/1)
    |> to_bbox()
  end

  def spatial_to_bbox(_), do: nil

  defp to_bbox(geom) do
    geom
    |> Enum.flat_map(&parse_to_points/1)
    |> calculate_bbox_from_points()
  end

  @doc """
  Converts CMR spatial data to GeoJSON geometry objects.

  ## Parameters
  - spatial_map: A map containing one of the following geometry types:
    - %{"points" => points} - List of point coordinates
    - %{"lines" => lines} - List of line coordinates
    - %{"boxes" => boxes} - List of box coordinates
    - %{"polygons" => polygons} - List of polygon coordinates

  ## Returns
  One of the following GeoJSON geometry objects:

  For single geometries:
  - Point: %{"type" => "Point", "coordinates" => [lon, lat]}
  - LineString: %{"type" => "LineString", "coordinates" => [[lon, lat, ...]}
  - Polygon: %{"type" => "Polygon", "coordinates" => [[[lon, lat], ...]]}

  For multiple geometries:
  - %{"type" => "GeometryCollection", "geometries" => [geometry, ...]}

  ## Geometry Types Details

  ### Points
  - Single point returns a Point geometry
  - Multiple points return a GeometryCollection of Points

  ### Lines
  - Single line returns a LineString geometry
  - Multiple lines return a GeometryCollection of LineStrings

  ### Boxes
  - Converts box coordinates to closed Polygon geometries
  - Single box returns a Polygon geometry
  - Multiple boxes return a GeometryCollection of Polygons
  - Automatically closes the ring by repeating the first coordinate

  ### Polygons
  - Converts polygon coordinates to GeoJSON Polygon format
  - Single polygon returns a Polygon geometry
  - Multiple polygons return a GeometryCollection of Polygons
  - Automatically closes the ring by repeating the first coordinate

  ## Examples

    iex> Altabarra.Stac.GeoUtils.spatial_to_geometry(%{"points" => ["0.0 100.0"]})
    %{"type" => "Point", "coordinates" => [100.0, 0.0]}

    iex> Altabarra.Stac.GeoUtils.spatial_to_geometry(%{"boxes" => ["0.0 100.0 1.0 101.0"]})
    %{
    "type" => "Polygon",
    "coordinates" => [
        [[100.0, 0.0], [100.0, 1.0], [101.0, 1.0], [101.0, 0.0], [100.0, 0.0]]
      ]
    }

  ## Note
  The returned geometries conform to the GeoJSON specification:
  https://datatracker.ietf.org/doc/html/rfc7946#section-3.1
  """
  def spatial_to_geometry(%{"points" => points}) do
    points
    |> Enum.flat_map(&parse_to_points/1)
    |> Enum.map(fn {lon, lat} -> %{"type" => "Point", "coordinates" => [lon, lat]} end)
    |> consolidate_geometries
  end

  def spatial_to_geometry(%{"lines" => lines}) do
    lines
    |> Enum.map(&parse_to_points/1)
    |> Enum.map(fn line_points ->
      %{
        "type" => "LineString",
        "coordinates" => line_points |> Enum.map(&Tuple.to_list/1)
      }
    end)
    |> consolidate_geometries
  end

  def spatial_to_geometry(%{"boxes" => boxes}) do
    boxes
    |> Enum.map(&parse_to_points/1)
    |> Enum.map(&calculate_bbox_from_points/1)
    |> Enum.map(fn [w, s, e, n] ->
      coordinates = [
        [w, s],
        [w, n],
        [e, n],
        [e, s],
        # close the ring
        [w, s]
      ]

      %{
        "type" => "Polygon",
        "coordinates" => [coordinates]
      }
    end)
    |> consolidate_geometries
  end

  def spatial_to_geometry(%{"polygons" => polygons}) do
    polygons
    |> Enum.flat_map(fn ring -> ring |> Enum.map(&parse_to_points/1) end)
    |> Enum.map(fn points ->
      coordinates =
        points
        |> Enum.map(&Tuple.to_list/1)
        |> close_ring

      %{
        "type" => "Polygon",
        "coordinates" => [coordinates]
      }
    end)
    |> consolidate_geometries
  end

  defp consolidate_geometries([geometry]), do: geometry

  defp consolidate_geometries(geometries) do
    %{"type" => "GeometryCollection", "geometries" => geometries}
  end

  defp calculate_bbox_from_points([{lon, lat}]) do
    lat_d = lat_delta()
    lon_d = lon_delta(lat)

    [
      max(lon - lon_d, @min_longitude),
      max(lat - lat_d, @min_latitude),
      min(lon + lon_d, @max_longitude),
      min(lat + lat_d, @max_latitude)
    ]
  end

  defp calculate_bbox_from_points(points) do
    points
    |> Enum.reduce(
      {@max_longitude, @max_latitude, @min_longitude, @min_latitude},
      fn {lon, lat}, {west, south, east, north} ->
        {min(west, lon), min(south, lat), max(east, lon), max(north, lat)}
      end
    )
    |> Tuple.to_list()
  end

  def lat_delta(meters \\ @bbox_default_meters), do: meters / @earth_radius_meters

  def lon_delta(latitude, meters \\ @bbox_default_meters) do
    meters / (@earth_radius_meters * :math.cos(latitude * :math.pi() / 180))
  end

  defp parse_to_points(geometry) when is_binary(geometry) do
    geometry
    |> String.split(~r/\s+/, trim: true)
    |> Enum.chunk_every(2)
    |> Enum.map(&convert_cmr_coords_to_stac/1)
  end

  defp convert_cmr_coords_to_stac([lat_str, lon_str]) do
    with {lat, ""} <- Float.parse(lat_str),
         {lon, ""} <- Float.parse(lon_str) do
      # CMR to STAC coord order conversion happens here
      {lon, lat}
    else
      _ -> {:error, "Invalid geometry format"}
    end
  end

  defp close_ring([]), do: []

  defp close_ring(coordinates) do
    first_point = List.first(coordinates)
    last_point = List.last(coordinates)

    if first_point == last_point do
      coordinates
    else
      coordinates ++ [first_point]
    end
  end
end
