defmodule Altabarra.Stac.GeoUtils do
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
  def point_to_bbox(lat, lon, delta \\ 0.0001) do
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

  defp process_points(points) when is_list(points) and length(points) > 0 do
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

  defp process_points(_), do: nil

  defp process_lines(lines) when is_list(lines) and length(lines) > 0 do
    # Flatten the list of lines into a single list of points
    points = Enum.flat_map(lines, fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_float/1)
      |> to_points()
    end)

    calculate_bbox_from_points(points)
  end

  defp to_points([lat1, lon1, lat2, lon2]) do
    [%{"lon" => lon1, "lat" => lat1}, %{"lon" => lon2, "lat" => lat2}]
  end

  defp process_lines(_), do: nil

  defp process_bboxes(bboxes) when is_list(bboxes) and length(bboxes) > 0 do
    # Initial bounding box covering the whole world S W N E
    initial_bbox = [-90, -180, 90, 180]

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
        max(Enum.at(bbox, 0, -90), Enum.at(acc, 0)),
        # west
        max(Enum.at(bbox, 1, -180), Enum.at(acc, 1)),
        # north
        min(Enum.at(bbox, 2, 90), Enum.at(acc, 2)),
        # east
        min(Enum.at(bbox, 3, 180), Enum.at(acc, 3))
      ]
    end)
  end

  defp process_bboxes(_), do: nil

  defp calculate_bbox_from_points(points) do
    {min_lon, min_lat, max_lon, max_lat} =
      Enum.reduce(points, {180, 90, -180, -90}, fn point, {min_lon, min_lat, max_lon, max_lat} ->
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
