# <img src="private/images/logo.svg" width="32" height="32" style="position: relative; top: 5px;"> ProgrammingNewsletters.com

>The best weekly programming newsletters on one website

## Features

- Ordered by last update
- Filter by category
- No email needed
- No CloudFlare
- No analytics
- Free

## Development

### Building the site

To build the site:

```bash
carton exec perl Run.pm
```

To force a rebuild, overriding newsletters cache:

```bash
carton exec perl Run.pm --build
```

### Viewing the site locally

Download the code and start a webserver.

```bash
git clone git@github.com:szTheory/easynewsletter.git
cd easynewsletter
python3 -m http.server --directory public
```

Now visit `localhost:8000` to view the website.

## Credits

Logo icon made by [Freepik](https://www.flaticon.com/authors/freepik)