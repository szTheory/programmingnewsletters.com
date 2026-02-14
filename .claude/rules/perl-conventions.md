# Perl Conventions

## Module Boilerplate

Every `.pm` file follows this exact pattern:

```perl
package Name 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(function_name CONSTANT);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use lib 'lib';
# ... imports ...

# ... code ...

1;
```

## Constants

- Use `use constant NAME => value;` — not Readonly or other modules
- All-caps naming: `API_PATH`, `GET_TIMEOUT`, `ENTRY_KEYS_WHITELIST`

## File I/O

Three-argument open with explicit encoding:

```perl
open my $fh, '<:encoding(UTF-8)', $filename;
```

Use `File::Spec->catfile()` for path construction. `autodie` handles errors implicitly.

## Naming

- Private functions: underscore prefix (`_helper_name`)
- Public functions: plain snake_case (`presenter`, `cached_newsletters`)
- Variables: snake_case (`$should_rebuild`, `$grouped_entries`)
- Modules: PascalCase (`Build.pm`, `Newsletters.pm`)

## Style

- Args via list assignment: `my ($arg1, $arg2) = @_;`
- Explicit `return;` at end of void subs
- No Moose/Moo OOP — pure procedural with Exporter
- Hashrefs and arrayrefs for complex data structures

## Dependencies (exact module names)

Use these specific modules — not alternatives:
- `JSON::MaybeXS` (not JSON or JSON::PP)
- `List::SomeUtils` (not List::MoreUtils)
- `Mojo::Template`, `Mojo::DOM`, `Mojo::Util` (from Mojolicious)
- `LWP::UserAgent` + `LWP::Protocol::https`
- `XML::Twig` for RSS/XML parsing
- `CSS::Packer`, `HTML::Packer`, `JavaScript::Packer` for minification
- `DateTime::Format::DateParse`, `Date::Manip` for timestamp parsing

Managed by Carton: `cpanfile` (manifest) + `cpanfile.snapshot` (lockfile).
