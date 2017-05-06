# Ruby INI file parser - fun exercise

## Design choices

- Uses lazy evaluation to create the methods for the queries (method_missing) for returning the object quickly.
- File.foreach for parsing the file one line at a time.
- Used rubocop for style & complexity analysis


## Testing strategies

- Rspec + Variety of edge cases
- Mostly integration tests due to shortage of time.

## Notes

- The lib/load_config.rb contains the defined method: load_config.
- Used ruby 2.1.4
