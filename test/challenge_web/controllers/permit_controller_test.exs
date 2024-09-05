defmodule ChallengeWeb.UserControllerTest do
  use ChallengeWeb.ConnCase, async: true

  alias Challenge.Permits

  describe "GET /permits" do
    test "no permits", %{conn: conn} do
      conn = get(conn, ~p"/api/permits")

      assert %{
               "entries" => [],
               "page_number" => 1,
               "page_size" => 20,
               "total_pages" => 1,
               "total_entries" => 0
             } = json_response(conn, 200)["data"]
    end

    test "filter by status", %{conn: conn} do
      for n <- 1..5 do
        status = if rem(n, 2) == 0, do: "approved", else: "expired"

        %{
          "location_id" => n,
          "status" => status
        }
        |> permit()
        |> upsert!()
      end

      conn = get(conn, ~p"/api/permits?status=approved")

      assert %{
               "entries" => entries,
               "page_number" => 1,
               "page_size" => 20,
               "total_pages" => 1,
               "total_entries" => 2
             } = json_response(conn, 200)["data"]

      assert length(entries) == 2
    end

    test "filter by term", %{conn: conn} do
      for n <- 1..5 do
        %{
          "location_id" => n,
          "food_items" => "food #{n}"
        }
        |> permit()
        |> upsert!()
      end

      conn = get(conn, ~p"/api/permits?q=food%202")

      assert %{
               "entries" => entries,
               "page_number" => 1,
               "page_size" => 20,
               "total_pages" => 1,
               "total_entries" => 1
             } = json_response(conn, 200)["data"]

      assert length(entries) == 1
    end

    test "pagination", %{conn: conn} do
      for n <- 1..5 do
        %{"location_id" => n}
        |> permit()
        |> upsert!()
      end

      page = 2
      page_size = 1

      conn = get(conn, ~p"/api/permits?page=#{page}&page_size=#{page_size}")

      assert %{
               "entries" => entries,
               "page_number" => ^page,
               "page_size" => ^page_size,
               "total_pages" => 5,
               "total_entries" => 5
             } = json_response(conn, 200)["data"]

      assert length(entries) == page_size
    end
  end

  defp permit(attrs) do
    %{
      "location_id" => "1234",
      "location_description" => "1ST ST => LYMAN AVE to TAPESTRY RDG",
      "permit_number" => "23MFF-00030",
      "permit_holder" => "Bill's Snacks",
      "food_items" => "American Food: Hot dogs: pretzels: beverages",
      "hours_of_operation" => "Mo-Fr:12PM-8PM",
      "status" => "approved"
    }
    |> Map.merge(attrs)
  end

  defp upsert!(attrs) do
    {:ok, permit} = Permits.upsert_permit(attrs)
    permit
  end
end
