defmodule SongExplorer.Repo.Migrations.CreateArtists do
  use Ecto.Migration

  def change do
    create table(:artists) do
      add :name, :string
      add :deezer_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
