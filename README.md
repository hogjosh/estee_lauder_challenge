# FeedMe

FeedMe is an API that queries for food trucks in San Francisco, based on publicly available permit information.

## Setup

You will need the following installed:

  * Erlang >= 27.0.1
  * Elixir >= 1.17.2-otp-27
  * Postgres >= 15

It's possible everything will work fine using older versions, but these are the versions I've developed against. Check out the `.tool-versions` file for version information.

Erlang and Elixir can be installed using [`asdf`](https://github.com/asdf-vm/asdf) by running `asdf install` in the base of the repo.

One option for installing Postgres is via [`homebrew`](https://brew.sh), by running `brew install postgresql@15`. Note that, by default, the application expects a Postgres user and password of `postgres`.

To start the server:

  * Run `mix setup` to install and setup project dependencies
  * Start the server with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000/api/permits`](http://localhost:4000/api/permits) from your browser.

## API

  * `GET /api/permits`
    - Responds with a page of permits in the following sample format:
    - Query parameters:
      - "q" - (optional) A term to search for in permits
      - "status" - (optional) Filter permits by status
      - "page" - (optional) The page number to respond with, defaults to 1
      - "page_size" - (optional) The maximum number of results per page, defaults to 20
    - example: `curl -H "Accept: application/json" "localhost:4000/api/permits?q=pretzel&page=2&page_size=10"`
    ```json
    {
      "data": {
        "page_size": 20,
        "page_number": 1,
        "entries": [
          {
            "id": "71b01d25-faac-4687-8e6b-831befd6ac78",
            "location_id": 1750838,
            "location_description": "PIERCE ST: CHESTNUT ST to TOLEDO WAY (3300 - 3337)",
            "permit_number": "24MFF-00018",
            "permit_holder": "EggTasy LLC",
            "food_items": "Soft Pretzels: hot dogs: sausage: chips: popcorn: soda: espresso: cappucino: pastries: ice cream: italian sausages: shish-ka-bob: churros: juice: water: various drinks",
            "hours_of_operation": "Mo-Fr:12PM-8PM",
            "status": "approved",
          }
        ],
        "total_entries": 1,
        "total_pages": 1,
      }
    }
    ```

## Implementation

### Database schema

- Permits information is stored in a single `permits` table
- A uuid is generated for each record
- It's difficult to assert anything about data you do not own or control, but I made the assumption that `location_id` will be unique. The unique constraint on this column allows us to perform upserts when seeding the database.
- Leverage trigram indices on the 'searchable' columns.
  - Using the default Postgres index on these columns would require a full table scan to match wildcards at the beginning of the search term, eg. `ILIKE %term`. This will hurt query performance.
  - A trigram index gives us the ability to use `ILIKE %term%` to perform a case insensitive substring match with solid performance. 
  - It's a relatively low lift, as compared to implementing Postgres full text search, or something like elasticsearch.
  - This does require a postgres extension that may not be available on all platforms.

### Permits context

- `upsert_permit/1`
  - This function is only used in tests and when seeding the database, but validating permits at time of insertion makes the functionality more robust and worry free.
  - In the case of a conflict on `location_id`, the conflicting row will instead be updated with the attributes provided. This allows the seeding process to be idempotent. 

- `page_permits/1`
  - This function acts as the core entry point for permit queries.
  - It builds a paginated query using the [`scrivener_ecto`](https://github.com/drewolson/scrivener_ecto) library. Paginated data helps prevent dumping the whole database in a single query.
    - The lib only supports offset/limit paging. These queries are easy to implement and understand, but early pages will return faster than later pages since Postgres has to scan all the results up to the requested page.
    - An alternative approach would be keyset pagination. A bit more complex since it is stateful and the state has to be de/serialized between client and server - ideally without leaking implementation details. However, we could get page results without scanning earlier pages.
  - We can use `ILIKE` queries without hurting performance due to trigram indices mentioned above.
  - The search query works well, but does have limitations:
    - Punctuation in the data must also be in the search term. eg. "Bills" would not match on "Bill's"
    - White space characters in the search term must also be in the data.
    - We cannot (easily) support multiple search terms. eg. May not get expected results searching for "Main st hot dogs"
  - Additional options will be relatively straightforward to integrate.

### Seeding
- The majority of the seed functionality is baked into the app as formal modules. This allows us to unit test the process. The seeds.exs script simply reads the file and delegates to the seed functionality.
- The seeding process is idempotent so if it fails we can safely run it again without duplicating data.

### Web

- The permits controller implementation is simple and straightforward, as I think they should be.
  - Translates a web request into the corresponding function call and renders the result as json.
- It could be worth removing unused functionality from the router/endpoint to simplify the code and lower the API surface for security purposes. Most of what is there was generated by `phx.new`.

### Tests

- Overall, I'm happy with the tests.
- Defining some formal, shared factories would simplify test setup, particularly as the project grows.

## Future enhancements

- Integrate OpenTelemetry and something like [OpenObserve](https://openobserve.ai/)
- Implement rate limiting to prevent abuse
- Expose a formal OpenAPI spec
- Build a streamlined and easy way to update the permit data.
  - Should implement a proper merge. For example, if a record is no longer represented in the csv, it should be removed from the database.
- Define and formalize a deploy process using [fly.io](https://fly.io/) or similar
- Formalize CI/CD using github actions, or similar



