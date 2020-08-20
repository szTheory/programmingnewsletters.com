# EasyNewsletter

>weekly programming newsletters without an email subscription

## Building

To build the site:

```bash
carton exec perl
```

To force a rebuild, overriding newsletters cache:

```bash
carton exec perl --build
```

## Development

Download the code and start a webserver.

```bash
git clone git@github.com:szTheory/easynewsletter.git
cd easynewsletter
python3 -m http.server --directory public
```

Now visit `localhost:8000` to view the website.
