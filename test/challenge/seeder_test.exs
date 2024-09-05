defmodule Challenge.SeederTest do
  use Challenge.DataCase, async: true

  alias Challenge.Seeder
  alias Challenge.Permits
  alias Challenge.Permits.Permit
  alias Scrivener.Page

  describe "seed_permits/1" do
    test "success" do
      attrss = [permit(%{"location_id" => "1234"})]

      assert :ok = Seeder.seed_permits(attrss)

      assert %Page{
               entries: [%Permit{location_id: 1234}]
             } = Permits.page_permits()
    end

    test "partial success" do
      attrss = [
        permit(%{"location_id" => "1234"}),
        permit(%{"location_id" => ""})
      ]

      # Seed with chunk size 1 to illustrate chunks will be inserted successfully
      # up until failure.
      assert {:error, %Ecto.Changeset{} = changeset} = Seeder.seed_permits(attrss, 1)

      refute changeset.valid?

      # The second chunk fails
      assert %{location_id: ["can't be blank"]} == errors_on(changeset)

      # The first chunk was inserted successfully
      assert %Page{
               entries: [%Permit{location_id: 1234}]
             } = Permits.page_permits()
    end

    test "failure" do
      attrss = [permit(%{"location_id" => ""})]

      assert {:error, %Ecto.Changeset{} = changeset} = Seeder.seed_permits(attrss)

      refute changeset.valid?

      assert %{location_id: ["can't be blank"]} == errors_on(changeset)

      assert %Page{entries: []} = Permits.page_permits()
    end
  end

  defp permit(attrs) do
    %{
      "location_id" => "1723825",
      "permit_holder" => "Natan's Catering",
      "location_description" => "KANSAS ST: 16TH ST to 17TH ST (300 - 399)",
      "permit_number" => "23MFF-00006",
      "status" => "approved",
      "food_items" => "Burgers: melts: hot dogs: burritos:sandwiches: fries: onion rings: drinks",
      "hours_of_operation" => ""
    }
    |> Map.merge(attrs)
  end
end
