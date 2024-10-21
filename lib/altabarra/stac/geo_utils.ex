defmodule Altabarra.Stac.GeoUtils do
  @moduledoc """
  BBOX in STAC is defined as [west, south, east, north]

  The first coordinate (west) is the minimum longitude.
  The second coordinate (south) is the minimum latitude.
  The third coordinate (east) is the maximum longitude.
  The fourth coordinate (north) is the maximum latitude.
  """
  # WEST
  @min_longitude -180

  # SOUTH
  @min_latitude -90

  # EAST
  @max_longitude 180

  # NORTH
  @max_latitude 90

  @delta 0.0001

  defp point_to_bbox({lat, lon}, delta \\ @delta) do
    [
      # west
      max(lon - delta, @min_longitude),
      # south
      max(lat - delta, @min_latitude),
      # east
      min(lon + delta, @max_longitude),
      # north
      min(lat + delta, @max_longitude)
    ]
  end

  defp calculate_bbox_from_points(points) do
    {west, south, east, north} =
      Enum.reduce(
        points,
        {@max_longitude, @max_latitude, @min_longitude, @min_latitude},
        fn {lat, lon}, {west, south, east, north} ->
          {
            min(west, lon),
            min(south, lat),
            max(east, lon),
            max(north, lat)
          }
        end
      )

    [west, south, east, north]
  end

  def spatial_to_bbox(%{"points" => points}) do
    parsed_points = parse_points(points)

    if length(parsed_points) == 1 do
      [point | _] = parsed_points
      point_to_bbox(point)
    else
      calculate_bbox_from_points(parsed_points)
    end
  end

  def spatial_to_bbox(%{"lines" => lines}) do
    parsed_lines = Enum.flat_map(lines, &parse_line/1)
    calculate_bbox_from_points(parsed_lines)
  end

  def spatial_to_bbox(%{"boxes" => boxes}) do
    parsed_boxes = Enum.flat_map(boxes, &parse_box/1)
    calculate_bbox_from_points(parsed_boxes)
  end

  def spatial_to_bbox(%{"polygons" => polygons}) do
    parsed_polygons = Enum.flat_map(polygons, &parse_polygon/1)
    calculate_bbox_from_points(parsed_polygons)
  end

  def spatial_to_bbox(_item) do
    nil
  end

  defp parse_points(points) do
    Enum.map(points, &parse_point/1)
  end

  defp parse_point(point) do
    point
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&Float.parse/1)
    |> extract_coordinates()
  end

  defp parse_line(line) do
    line
    |> String.split(~r/\s+/, trim: true)
    |> Enum.chunk_every(2)
    |> Enum.map(&parse_coordinates/1)
  end

  defp parse_box(box) do
    # NOTE: CMR boxes do [lat lon, lat lon], NOT [lon,lat]
    [south, west, north, east] =
      box
      |> String.split(~r/\s+/, trim: true)
      |> Enum.map(&Float.parse/1)
      |> Enum.map(&elem(&1, 0))

    [{west, south}, {east, north}]
  end

  defp parse_polygon(polygon) when is_binary(polygon) do
    polygon
    |> String.split(~r/\s+/, trim: true)
    |> Enum.chunk_every(2)
    |> Enum.map(&parse_coordinates/1)
  end

  defp parse_polygon(polygon) when is_list(polygon) do
    polygon
    |> List.first()
    |> String.split(~r/\s+/, trim: true)
    |> Enum.chunk_every(2)
    |> Enum.map(&parse_coordinates/1)
  end

  defp parse_coordinates([lon_str, lat_str]) do
    {Float.parse(lon_str) |> elem(0), Float.parse(lat_str) |> elem(0)}
  end

  defp extract_coordinates([{longitude, _}, {latitude, _}]) do
    {longitude, latitude}
  end
end
