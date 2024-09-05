defmodule Challenge.Repo.Migrations.CreatePgTrgmExtension do
  use Ecto.Migration

  # We need the [pg_trgm](https://www.postgresql.org/docs/15/pgtrgm.html) extension to easily support string searches and filtering.
  # This will allow us to, for example, use simple like/ilike queries with minimal
  # performance penalty.  
  # Note that we still have to create the proper kind of index on the columns.
  #
  # Another alternative would be using Postgres built in [full text search](https://www.postgresql.org/docs/15/textsearch.html).
  # Based on the current needs of the application and the relatively small amount 
  # of data involved, full text search is much more than we need.

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
  end

  def down do
    execute "DROP EXTENSION IF EXISTS pg_trgm;"
  end
end
