defmodule Challenge.Repo.Migrations.CreateUniqueIndexOnLocationId do
  use Ecto.Migration

  def change do
    create unique_index("permits", :location_id)
  end
end
