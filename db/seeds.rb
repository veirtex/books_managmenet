# Fictional demo data for browsing, filtering, CSV exports, and owner permissions.
# Re-running seeds preserves existing records and passwords.
if Rails.env.development?
  authors = [
    {
      name: "Maya Bennett", email: "maya@example.test",
      books: [
        [ "The Lantern Garden", "2018-04-12" ],
        [ "Letters from the Coast", "2020-09-03" ],
        [ "A Map of Small Wonders", "2023-06-15" ]
      ]
    },
    {
      name: "Oliver Reed", email: "oliver@example.test",
      books: [
        [ "Midnight at Harbor Station", "2019-11-07" ],
        [ "The Last Lighthouse", "2021-02-18" ],
        [ "Beyond the Northern Sea", "2023-06-15" ]
      ]
    },
    {
      name: "Sofia Marin", email: "sofia@example.test",
      books: [
        [ "The Art of Starting Again", "2017-03-21" ],
        [ "A Season for Quiet Things", "2022-08-09" ],
        [ "When the Garden Wakes", "2024-04-16" ]
      ]
    },
    {
      name: "Daniel Brooks", email: "daniel@example.test",
      books: [
        [ "Cities Made of Glass", "2016-10-25" ],
        [ "The Clockwork Horizon", "2020-09-03" ],
        [ "Signals from Tomorrow", "2025-01-14" ]
      ]
    },
    {
      name: "Nora Ellis", email: "nora@example.test",
      books: [
        [ "The Little Bookshop on Willow Street", "2015-05-19" ],
        [ "Winter Letters", "2021-12-02" ],
        [ "Three Days in September", "2024-09-10" ]
      ]
    }
  ]

  ApplicationRecord.transaction do
    authors.each do |data|
      author = Author.find_or_create_by!(email: data[:email]) do |record|
        record.name = data[:name]
        record.password = "DemoPassword123!"
        record.password_confirmation = "DemoPassword123!"
      end

      data[:books].each do |title, released_on|
        Book.find_or_create_by!(title: title) do |book|
          book.author = author
          book.published_at = Date.iso8601(released_on)
        end
      end
    end
  end

  puts "Demo seeds loaded. Database contains #{Author.count} authors and #{Book.count} books."
else
  puts "Skipping demo seeds outside development."
end
