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

  * x86   - `/opt/csw/lib/ruby/2.0.0/i386-solaris2.10/rbconfig.rb`
  * sparc - `/opt/csw/lib/ruby/2.0.0/sparc-solaris2.10/rbconfig.rb`

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
