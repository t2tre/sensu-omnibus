sensu Omnibus project
=====================
This project creates full-stack platform-specific packages for
`sensu`!

Preparing Build Environments
----------------------------

### Solaris 10 (x86/sparc)

1. Add the following lines to the end of `/etc/profile`, and then reconnect via SSH:

```sh
PATH=/opt/csw/bin:$PATH:/usr/ccs/bin:/usr/sfw/bin:/usr/openwin/bin:/usr/local/bin
TERM=xterm
export PATH
export TERM
```

2. Install the CSW repository tools:

```
pkgadd -d http://get.opencsw.org/now
pkgutil -U
```

3. Install dependencies via CSW:

```
pkgutil -y -i ruby20 ruby20_dev curl git gcc5core emacs_nox libffi6 libffi_dev
```

4. Patch Ruby's rbconfig.rb to use gcc:

* x86   - /opt/csw/lib/ruby/2.0.0/i386-solaris2.10/rbconfig.rb
* sparc - /opt/csw/lib/ruby/2.0.0/sparc-solaris2.10/rbconfig.rb

```
Change "-KPIC" to "-fPIC"
Set CC to "/opt/csw/bin/gcc-5.2"
Change "-xO3" to "-O3"
Remove "-xarch=sparc" (sparc-only)
Change "-xarch=" to "-march=" (x86-only)
Add "-I/opt/csw/lib/libffi-3.2.1/include" to CPPFLAGS
```

5. Install rake & bundler:

```
gem install rake bundler --no-rdoc --no-ri
```

6. Clone the omnibus-sensu directory:

```
git clone git@github.com:sensu/omnibus-sensu.git
```

7. Configure git:

```
git config --global user.email "justin@heavywater.io"
git config --global user.name "Justin Kolberg"
```

Installation
------------
You must have a sane Ruby 1.9+ environment with Bundler installed. Ensure all
the required gems are installed:

```shell
$ bundle install --binstubs
```

Usage
-----
### Build

You create a platform-specific package using the `build project` command:

```shell
$ bin/omnibus build sensu
```

The platform/architecture type of the package created will match the platform
where the `build project` command is invoked. For example, running this command
on a MacBook Pro will generate a Mac OS X package. After the build completes
packages will be available in the `pkg/` folder.

### Clean

You can clean up all temporary files generated during the build process with
the `clean` command:

```shell
$ bin/omnibus clean sensu
```

Adding the `--purge` purge option removes __ALL__ files generated during the
build including the project install directory (`/opt/sensu`) and
the package cache directory (`/var/cache/omnibus/pkg`):

```shell
$ bin/omnibus clean sensu --purge
```

### Publish

Omnibus has a built-in mechanism for releasing to a variety of "backends", such
as Amazon S3. You must set the proper credentials in your `omnibus.rb` config
file or specify them via the command line.

```shell
$ bin/omnibus publish path/to/*.deb --backend s3
```

### Help

Full help for the Omnibus command line interface can be accessed with the
`help` command:

```shell
$ bin/omnibus help
```

Version Manifest
----------------

Git-based software definitions may specify branches as their
default_version. In this case, the exact git revision to use will be
determined at build-time unless a project override (see below) or
external version manifest is used.  To generate a version manifest use
the `omnibus manifest` command:

```
omnibus manifest PROJECT -l warn
```

This will output a JSON-formatted manifest containing the resolved
version of every software definition.


Kitchen-based Build Environment
-------------------------------
Every Omnibus project ships will a project-specific
[Berksfile](http://berkshelf.com/) that will allow you to build your omnibus projects on all of the projects listed
in the `.kitchen.yml`. You can add/remove additional platforms as needed by
changing the list found in the `.kitchen.yml` `platforms` YAML stanza.

This build environment is designed to get you up-and-running quickly. However,
there is nothing that restricts you to building on other platforms. Simply use
the [omnibus cookbook](https://github.com/opscode-cookbooks/omnibus) to setup
your desired platform and execute the build steps listed above.

The default build environment requires Test Kitchen and VirtualBox for local
development. Test Kitchen also exposes the ability to provision instances using
various cloud providers like AWS, DigitalOcean, or OpenStack. For more
information, please see the [Test Kitchen documentation](http://kitchen.ci).

Once you have tweaked your `.kitchen.yml` (or `.kitchen.local.yml`) to your
liking, you can bring up an individual build environment using the `kitchen`
command.

```shell
$ bin/kitchen converge ubuntu-1204
```

Then login to the instance and build the project as described in the Usage
section:

```shell
$ bundle exec kitchen login ubuntu-1204
[vagrant@ubuntu...] $ cd sensu
[vagrant@ubuntu...] $ bundle install
[vagrant@ubuntu...] $ ...
[vagrant@ubuntu...] $ bin/omnibus build sensu
```

For a complete list of all commands and platforms, run `kitchen list` or
`kitchen help`.
