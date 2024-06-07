# <img src="private/images/logo.svg" width=25 height=25>ProgrammingNewsletters.com

> The best weekly programming newsletters on one website

## Features

- Ordered by last update
- Filter by category
- No email needed
- No CloudFlare
- No analytics
- Free

## Development

[![Trigger Netlify Build](https://github.com/szTheory/programmingnewsletters.com/actions/workflows/main.yml/badge.svg)](https://github.com/szTheory/programmingnewsletters.com/actions/workflows/main.yml)

### Installing Perl and Carton deps

Perl

```bash
asdf plugin add perl https://github.com/ouest/asdf-perl.git #Install Perl plugin for asdf
asdf install perl 5.22.1 #Install latest Perl version at time of writing
asdf global perl 5.22.1 #Use as default Perl
perl --version #Confirm latest version is installed properly
```

cpanminus module installer (needed for Carton)

```bash
curl -L https://cpanmin.us > cpanm_setup.pl #Download cpanm setup script
perl cpanm_setup.pl App::cpanminus #Run cpanm setup
```

Perl deps needed before Carton

```bash
cpanm XML::Parser
cpanm DateTime
```

Carton (Perl lib dependencies)

```bash
cpanm Carton #Install Carton
asdf reshim perl #Set up binary "shim" (command line shortcut)
carton install #Install module deps for project from the cpanfile
```

### Building the site

To build the site:

```bash
carton exec perl Run.pm
```

To force a rebuild, overriding newsletters cache:

```bash
carton exec perl Run.pm --rebuild
```

To build just the first item from `newsletter.json` (when adding new newsletters):

```bash
carton exec perl Run.pm --rebuild --first-only
```

### Viewing the site locally

Download the code and start a webserver.

```bash
git clone git@github.com:szTheory/programmingnewsletters.com.git
cd programmingnewsletters.com
python3 -m http.server --directory public
```

Now visit `localhost:8000` to view the website.

### Netlify deploy command

```bash
export PERL5LIB=/opt/buildhome/perl5/lib/perl5 && curl -L https://cpanmin.us | perl - App::cpanminus && /opt/buildhome/perl5/bin/cpanm Carton && /opt/buildhome/perl5/bin/carton install && /opt/buildhome/perl5/bin/carton exec perl Run.pm
```

## Credits

Logo icon made by [Freepik](https://www.flaticon.com/authors/freepik)
