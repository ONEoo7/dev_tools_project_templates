my-project
==========

This disk image contains "my-project", a self-contained command-line tool. It
includes its own Python, so nothing else needs to be installed.

Install
-------

Open Terminal and run:

    sudo mkdir -p /usr/local/lib /usr/local/bin
    sudo cp -R /Volumes/my-project/my-project /usr/local/lib/
    sudo ln -sf /usr/local/lib/my-project/my-project /usr/local/bin/my-project
    my-project --help

This build is not notarized by Apple. If macOS refuses to run it, clear the
download quarantine flag once:

    sudo xattr -dr com.apple.quarantine /usr/local/lib/my-project

Uninstall
---------

    sudo rm -rf /usr/local/lib/my-project /usr/local/bin/my-project
