defmodule Challenge.Repo.Migrations.CreateTrgmIndexOnLocationDescription do
  use Ecto.Migration

  def up do
    execute """
      CREATE INDEX permits_location_description_gin_trgm_idx
        ON permits
        USING gin (location_description gin_trgm_ops);
    """
  end

  def down do
    execute """
      DROP INDEX IF EXISTS permits_location_description_gin_trgm_idx;
    """
  end
end
