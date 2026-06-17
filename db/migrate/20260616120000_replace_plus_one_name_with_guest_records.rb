class ReplacePlusOneNameWithGuestRecords < ActiveRecord::Migration[7.2]
  # Plus-ones used to live as a free-text `plus_one_name` on the host guest.
  # They are now full Guest records in the same invite group, linked back to
  # the host via `plus_one_host_id`. Backfill any existing names so they aren't
  # lost when the column is dropped.
  def up
    add_reference :guests, :plus_one_host, foreign_key: { to_table: :guests }, null: true

    hosts = select_all(<<~SQL)
      SELECT id, invite_group_id, plus_one_name
      FROM guests
      WHERE plus_one = TRUE
        AND plus_one_name IS NOT NULL
        AND btrim(plus_one_name) <> ''
    SQL

    hosts.each do |row|
      first, last = split_name(row["plus_one_name"])
      execute(<<~SQL)
        INSERT INTO guests
          (invite_group_id, first_name, last_name, attending, plus_one,
           plus_one_allowed, plus_one_host_id, created_at, updated_at)
        VALUES
          (#{quote(row["invite_group_id"])}, #{quote(first)}, #{quote(last)},
           TRUE, FALSE, FALSE, #{quote(row["id"])}, now(), now())
      SQL
    end

    remove_column :guests, :plus_one_name
  end

  def down
    add_column :guests, :plus_one_name, :string
    remove_reference :guests, :plus_one_host, foreign_key: { to_table: :guests }
  end

  private

  # Best-effort split of a legacy single name string into first/last. Both
  # columns are required, so a single-word name is duplicated rather than left
  # blank.
  def split_name(full)
    parts = full.to_s.strip.split(/\s+/)
    return [ parts.first, parts.first ] if parts.length <= 1

    [ parts[0..-2].join(" "), parts.last ]
  end
end
