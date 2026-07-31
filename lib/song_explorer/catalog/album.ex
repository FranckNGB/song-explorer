defmodule SongExplorer.Catalog.Album do
  @moduledoc """
  Schéma Ecto représentant un album musical.

  ## Champs
    - `title` : titre de l'album
    - `release_date` : date de sortie de l'album

  ## Relations
    - `belongs_to :artist` : artiste auquel l'album est associé
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          title: String.t() | nil,
          release_date: Date.t() | nil,
          artist_id: integer() | nil,
          artist: SongExplorer.Catalog.Artist.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

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
    |> unique_constraint([:artist_id, :title], name: :albums_artist_id_title_index)
  end
end
