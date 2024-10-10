defmodule Altabarra.Stac.GeoUtils do

  @max_latitude 90
  @min_latitude -90
  @max_longitude 180
  @min_longitude -180

  @delta 0.0001

  @doc """
  Converts a single point to a minimal bounding box.
  The bounding box is created by adding and subtracting a small delta
  to the latitude and longitude.

  ## Parameters
    - lat: Latitude of the point
    - lon: Longitude of the point
    - delta: Small value to create the bounding box (default: 0.0001)

  ## Returns
    A list representing the bounding box: [west, south, east, north]
  """
  def point_to_bbox(lat, lon, delta \\ @delta) do
    [
      # west
      lon - delta,
      # south
      lat - delta,
      # east
      lon + delta,
      # north
      lat + delta
    ]
  end

  @doc """
  Converts CMR spatial data to a STAC bounding box.

  ## Parameters
    - spatial_data: Map containing CMR spatial data (points, lines, or bboxes)

  ## Returns
    A list representing the bounding box: [west, south, east, north]
  """
  def cmr_spatial_to_stac_bbox(spatial_data) do
    cond do
      spatial_data["points"] -> process_points(spatial_data["points"])
      spatial_data["lines"] -> process_lines(spatial_data["lines"])
      spatial_data["boxes"] -> process_bboxes(spatial_data["boxes"])
      true -> nil
    end
  end

  defp process_points(points) do
    if length(points) == 1 do
      # Single point case
      [{latitude, _}, {longitude, _}] =
        points
        |> List.first()
        |> String.split(~r/\s/, trim: true)
        |> Enum.map(&Float.parse/1)

      point_to_bbox(latitude, longitude)
    else
      # Multiple points case
      calculate_bbox_from_points(points)
    end
  end

  defp process_lines(lines) do
    # Flatten the list of lines into a single list of points
    points = Enum.flat_map(lines, fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_float/1)
      |> to_points()
    end)

    calculate_bbox_from_points(points)
  end

  defp to_points([lon1, lat1, lon2, lat2]) do
    [%{"lon" => lon1, "lat" => lat1}, %{"lon" => lon2, "lat" => lat2}]
  end

  defp process_bboxes(bboxes) do
    # Initial bounding box covering the whole world S W N E
    initial_bbox = [@min_longitude, @min_latitude, @max_longitude, @max_latitude]

    Enum.reduce(bboxes, initial_bbox, fn box_string, acc ->
      bbox =
        box_string
        |> String.split(~r/\s+/)
        |> Enum.map(fn value ->
          case Float.parse(value) do
            {float, _} -> float
            :error -> nil
          end
        end)

      [
        # south
        min(Enum.at(bbox, 1, @min_latitude), Enum.at(acc, 1)),
        # west
        max(Enum.at(bbox, 0, @min_longitude), Enum.at(acc, 0)),
        # north
        min(Enum.at(bbox, 3, @max_latitude), Enum.at(acc, 3)),
        # east
        min(Enum.at(bbox, 2, @max_longitude), Enum.at(acc, 2))
      ]
    end)
  end

  defp calculate_bbox_from_points(points) do
    {min_lon, min_lat, max_lon, max_lat} =
      Enum.reduce(points, {@max_longitude, @max_latitude, @min_longitude, @min_latitude}, fn point, {min_lon, min_lat, max_lon, max_lat} ->
        {
          min(min_lon, point["lon"]),
          min(min_lat, point["lat"]),
          max(max_lon, point["lon"]),
          max(max_lat, point["lat"])
        }
      end)

    [min_lon, min_lat, max_lon, max_lat]
  end
end
