defmodule SongExplorer.Repo.Migrations.AddUniqueIndexToArtistsDeezerId do
  use Ecto.Migration

  def change do
    create unique_index(:artists, [:deezer_id])
  end
end
