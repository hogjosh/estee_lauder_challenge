defmodule Challenge.Repo.Migrations.CreateTrgmIndexOnFoodItems do
  use Ecto.Migration

  def up do
    execute """
      CREATE INDEX permits_food_items_gin_trgm_idx
        ON permits
        USING gin (food_items gin_trgm_ops);
    """
  end

  def down do
    execute """
      DROP INDEX IF EXISTS permits_food_items_gin_trgm_idx;
    """
  end
end
