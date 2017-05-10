#
# Copyright 2012-2014 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Use this software definition to fix the shebangs of binaries under embedded/bin
# to point to the embedded ruby.
#

name "shebang-cleanup"

default_version "0.0.3"

license :project_license
skip_transitive_dependency_licensing true

build do
  if windows?
    block "Update batch files to point at embedded ruby" do
      # Fix gem.bat
      File.open("#{install_dir}/embedded/bin/gem.bat", "w+") do |f|
        f.puts <<-EOF
@ECHO OFF
"%~dp0ruby.exe" "%~dpn0" %*
        EOF
      end
    end
  end
end
