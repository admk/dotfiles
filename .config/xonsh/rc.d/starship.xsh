from shutil import which as _which


if not _which('starship') and not ${...}.get('NO_STARSHIP'):
    print('Installing starship...')
    tmp_dir = $(mktemp -d).strip()
    tmp_path = pf"{tmp_dir}/install.sh"
    echo "POSIXLY_CORRECT=1" > @(tmp_path)
    curl -sS https://starship.rs/install.sh >> @(tmp_path)
    /bin/sh @(tmp_path) -y


if _which('starship'):
    xontrib load prompt_starship
