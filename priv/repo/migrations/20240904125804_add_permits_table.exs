defmodule Challenge.Repo.Migrations.AddPermitsTable do
  use Ecto.Migration

  def change do
    create table("permits", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :location_id, :integer, null: false
      add :location_description, :text, null: true
      add :permit_number, :string, size: 255, null: false
      add :permit_holder, :text, null: false
      add :food_items, :text, null: true
      add :hours_of_operation, :string, size: 255, null: true
      add :status, :string, size: 255, null: false

      timestamps(type: :timestamptz)
    end
  end
end
