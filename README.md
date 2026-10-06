# Setup

Requires Ruby 4.0.7, Rails 8.1.4, and PostgreSQL 18.6.

1. Install Ruby and PostgreSQL, and start PostgreSQL.
2. Install the gems:

   ```sh
   bundle install
   ```

3. Copy the database settings and fill in your PostgreSQL connection details:

   ```sh
   cp .env_example .env
   ```

   The PostgreSQL user must be able to create the development and test databases.

4. Prepare the databases and start the application:

   ```sh
   bin/rails db:prepare
   bin/rails server
   ```

Open http://localhost:3000 and choose **Sign up** on the login page.

Authors can browse and filter authors and books, create books, and edit or delete their own books. **Download CSV** exports the currently filtered books with book name, release date, and author name.

Author names and book names must be unique. Book names are unique across all authors. Release dates cannot be in the future. The book's name and release date are stored as `title` and `published_at`.

## Demo data

Load five fictional authors and fifteen books in development:

```sh
bin/rails db:seed
```

Log in with `maya@example.test` and password `DemoPassword123!`.
The other demo accounts are `oliver@example.test`, `sofia@example.test`,
`daniel@example.test`, and `nora@example.test`, using the same password.
Each author owns three books. Try filtering book names by `Letters` or release
dates by `2023-06-15`, or switch accounts to try the owner permissions.

Seeds can be run again without duplicating or overwriting existing records or
passwords. Demo data is skipped outside development.

## Tests

```sh
bin/rails db:test:prepare
bin/rails test
```
