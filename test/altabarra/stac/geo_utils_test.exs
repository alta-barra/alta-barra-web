defmodule Altabarra.Stac.GeoUtilsTest do
  use ExUnit.Case, async: true
  alias Altabarra.Stac.GeoUtils

  describe "spatial_to_bbox/1" do
    test "handles single point conversion" do
      data = %{"points" => ["45.0 -93.0"]}
      [w, s, e, n] = GeoUtils.spatial_to_bbox(data)

      assert_in_delta w, -93.0, 0.001
      assert_in_delta s, 45.0, 0.001
      assert_in_delta e, -93.0, 0.001
      assert_in_delta n, 45.0, 0.001
    end

    test "handles multiple point conversion" do
      data = %{"points" => ["-57.74 -62.32", "-58.02 -62.42"]}
      [w, s, e, n] = GeoUtils.spatial_to_bbox(data)

      assert_in_delta w, -62.42, 0.001
      assert_in_delta s, -58.02, 0.001
      assert_in_delta e, -62.32, 0.001
      assert_in_delta n, -57.74, 0.001
    end

    test "handles single line conversion" do
      data = %{"lines" => ["40.0 -70.0 41.0 -71.0"]}
      [w, s, e, n] = GeoUtils.spatial_to_bbox(data)

      assert_in_delta w, -71.0, 0.001
      assert_in_delta s, 40.0, 0.001
      assert_in_delta e, -70.0, 0.001
      assert_in_delta n, 41.0, 0.001
    end

    test "handles multiple line conversion" do
      data = %{"lines" => ["40.0 -70.0 41.0 -71.0", "42.0 -72.0 43.0 -73.0"]}
      [w, s, e, n] = GeoUtils.spatial_to_bbox(data)

      assert_in_delta w, -73.0, 0.001
      assert_in_delta s, 40.0, 0.001
      assert_in_delta e, -70.0, 0.001
      assert_in_delta n, 43.0, 0.001
    end

    test "handles single box conversion" do
      data = %{"boxes" => ["40.0 -70.0 41.0 -71.0"]}
      [w, s, e, n] = GeoUtils.spatial_to_bbox(data)

      assert_in_delta s, -71.0, 0.001
      assert_in_delta w, 40.0, 0.001
      assert_in_delta n, -70.0, 0.001
      assert_in_delta e, 41.0, 0.001
    end

    test "handles multiple box conversion" do
      data = %{"boxes" => ["40.0 -70.0 41.0 -71.0", "42.0 -72.0 43.0 -73.0"]}
      [w, s, e, n] = GeoUtils.spatial_to_bbox(data)

      assert_in_delta s, -73.0, 0.001
      assert_in_delta w, 40.0, 0.001
      assert_in_delta n, -70.0, 0.001
      assert_in_delta e, 43.0, 0.001
    end

    test "handles single polygon conversion" do
      data = %{"polygons" => ["40.0 -70.0 41.0 -71.0 40.5 -70.5 40.0 -70.0"]}
      [w, s, e, n] = GeoUtils.spatial_to_bbox(data)

      assert_in_delta w, -71.0, 0.001
      assert_in_delta s, 40.0, 0.001
      assert_in_delta e, -70.0, 0.001
      assert_in_delta n, 41.0, 0.001
    end

    test "handles polygon list conversion" do
      data = %{
        "polygons" => [
          ["40.0 -70.0 41.0 -71.0 40.5 -70.5 40.0 -70.0"]
        ]
      }

      [w, s, e, n] = GeoUtils.spatial_to_bbox(data)

      assert_in_delta w, -71.0, 0.001
      assert_in_delta s, 40.0, 0.001
      assert_in_delta e, -70.0, 0.001
      assert_in_delta n, 41.0, 0.001
    end

    test "handles multiple polygon conversion" do
      data = %{
        "polygons" => [
          "40.0 -70.0 41.0 -71.0 40.5 -70.5 40.0 -70.0",
          "42.0 -72.0 43.0 -73.0 42.5 -72.5 42.0 -72.0"
        ]
      }

      [w, s, e, n] = GeoUtils.spatial_to_bbox(data)

      assert_in_delta w, -73.0, 0.001
      assert_in_delta s, 40.0, 0.001
      assert_in_delta e, -70.0, 0.001
      assert_in_delta n, 43.0, 0.001
    end
  end
end
