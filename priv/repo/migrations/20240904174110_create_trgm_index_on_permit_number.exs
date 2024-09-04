defmodule Challenge.Repo.Migrations.CreateTrgmIndexOnPermitNumber do
  use Ecto.Migration

  def up do
    execute """
      CREATE INDEX permits_permit_number_gin_trgm_idx
        ON permits
        USING gin (permit_number gin_trgm_ops);
    """
  end

  def down do
    execute """
      DROP INDEX IF EXISTS permits_permit_number_gin_trgm_idx;
    """
  end
end
