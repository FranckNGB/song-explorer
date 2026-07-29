defmodule SongExplorer.Catalog.Album do
  use Ecto.Schema
  import Ecto.Changeset

  schema "albums" do
    field :title, :string
    field :release_date, :date
    belongs_to :artist, SongExplorer.Catalog.Artist

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(album, attrs) do
    album
    |> cast(attrs, [:title, :release_date, :artist_id])
    |> validate_required([:title, :release_date])
  end
end
