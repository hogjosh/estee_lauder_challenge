defmodule Challenge.Repo.Migrations.CreateTrgmIndexOnPermitHolder do
  use Ecto.Migration

  def up do
    execute """
      CREATE INDEX permits_permit_holder_gin_trgm_idx
        ON permits
        USING gin (permit_holder gin_trgm_ops);
    """
  end

  def down do
    execute """
      DROP INDEX IF EXISTS permits_permit_holder_gin_trgm_idx;
    """
  end
end
