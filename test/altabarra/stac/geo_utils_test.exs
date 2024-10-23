defmodule Altabarra.Stac.GeoUtilsTest do
  use ExUnit.Case, async: true
  alias Altabarra.Stac.GeoUtils

  doctest Altabarra.Stac.GeoUtils

  describe "spatial_to_bbox/1" do
    test "handles single point conversion" do
      data = %{"points" => ["45.0 -93.0"]}

      assert GeoUtils.spatial_to_bbox(data) == [
               -93.0001270403847,
               44.9999101688825,
               -92.9998729596153,
               45.0000898311175
             ]
    end

    test "handles multiple point conversion" do
      data = %{"points" => ["-57.74 -62.32", "-58.02 -62.42"]}
      assert GeoUtils.spatial_to_bbox(data) == [-62.42, -58.02, -62.32, -57.74]
    end

    test "handles single line conversion" do
      data = %{"lines" => ["-70.0 40.0 -71.0 41.0"]}
      assert GeoUtils.spatial_to_bbox(data) == [40.0, -71.0, 41.0, -70.0]
    end

    test "handles multiple line conversion" do
      data = %{"lines" => ["-70.0 40.0 -71.0 41.0", "-72.0 42.0 -73.0 43.0"]}
      assert GeoUtils.spatial_to_bbox(data) == [40.0, -73.0, 43.0, -70.0]
    end

    test "handles single box conversion" do
      data = %{"boxes" => ["-70.0 40.0 -71.0 41.0"]}
      assert GeoUtils.spatial_to_bbox(data) == [40.0, -71.0, 41.0, -70.0]
    end

    test "handles multiple box conversion" do
      data = %{"boxes" => ["-70.0 40.0 -71.0 41.0", "-72.0 42.0 -73.0 43.0"]}
      assert GeoUtils.spatial_to_bbox(data) == [40.0, -73.0, 43.0, -70.0]
    end

    test "handles single polygon conversion" do
      data = %{"polygons" => [["-70.0 40.0 -71.0 41.0 -70.5 40.5 -70.0 40.0"]]}
      assert GeoUtils.spatial_to_bbox(data) == [40.0, -71.0, 41.0, -70.0]
    end

    test "handles polygon list conversion" do
      data = %{
        "polygons" => [
          ["-70.0 40.0 -71.0 41.0 -70.5 40.5 -70.0 40.0"]
        ]
      }

      assert GeoUtils.spatial_to_bbox(data) == [40.0, -71.0, 41.0, -70.0]
    end

    test "handles polygon with ring conversion" do
      data = %{
        "polygons" => [
          [
            "-70.0 40.0 -71.0 41.0 -70.5 40.5 -70.0 40.0",
            "-72.0 42.0 -73.0 43.0 -72.5 42.5 -72.0 42.0"
          ]
        ]
      }

      assert GeoUtils.spatial_to_bbox(data) == [40.0, -71.0, 41.0, -70.0]
    end

    test "handles multi-polygon conversion" do
      data = %{
        "polygons" => [
          [
            "-70.0 40.0 -71.0 41.0 -70.5 40.5 -70.0 40.0",
            "-72.0 42.0 -73.0 43.0 -72.5 42.5 -72.0 42.0"
          ],
          [
            "-80.0 40.0 -81.0 41.0 -80.5 40.5 -80.0 40.0"
          ]
        ]
      }

      assert GeoUtils.spatial_to_bbox(data) == [40.0, -81.0, 41.0, -70.0]
    end
  end

  describe "spatial_to_geometry/1" do
    test "handles single point conversion" do
      data = %{"points" => ["45.0 -93.0"]}
      geometry = GeoUtils.spatial_to_geometry(data)

      assert geometry == %{"type" => "Point", "coordinates" => [-93.0, 45.0]}
    end

    test "handles single box conversion" do
      data = %{"boxes" => ["45.0 -93.0 46.0 -92.0"]}
      geometry = GeoUtils.spatial_to_geometry(data)

      assert geometry == %{
               "type" => "Polygon",
               "coordinates" => [
                 [[-93.0, 45.0], [-93.0, 46.0], [-92.0, 46.0], [-92.0, 45.0], [-93.0, 45.0]]
               ]
             }
    end

    test "handles multi-point conversion" do
      data = %{"points" => ["45.0 -93.0", "33.3 -33.3"]}
      geometry = GeoUtils.spatial_to_geometry(data)

      assert geometry == %{
               "type" => "GeometryCollection",
               "geometries" => [
                 %{"coordinates" => [-93.0, 45.0], "type" => "Point"},
                 %{"coordinates" => [-33.3, 33.3], "type" => "Point"}
               ]
             }
    end

    test "handles single line conversion" do
      data = %{
        "lines" => [
          "37.7749 -122.4194 34.0522 -118.2437 33.4484 -112.0740"
        ]
      }

      geometry = GeoUtils.spatial_to_geometry(data)

      assert geometry == %{
               "type" => "LineString",
               "coordinates" => [
                 [-122.4194, 37.7749],
                 [-118.2437, 34.0522],
                 [-112.074, 33.4484]
               ]
             }
    end

    test "handles single polygon conversion" do
      data = %{
        "polygons" => [
          [
            "14.285717 -85.5010724 14.285717 -84.0269167 15.7142877 -84.5901986 15.7142877 -86.0742364 14.285717 -85.5010724"
          ]
        ]
      }

      geometry = GeoUtils.spatial_to_geometry(data)

      assert geometry == %{
               "type" => "Polygon",
               "coordinates" => [
                 [
                   [-85.5010724, 14.285717],
                   [-84.0269167, 14.285717],
                   [-84.5901986, 15.7142877],
                   [-86.0742364, 15.7142877],
                   [-85.5010724, 14.285717]
                 ]
               ]
             }
    end
  end
end
