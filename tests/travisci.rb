#!/usr/bin/env ruby

changed_files = `git diff HEAD^1 --name-only`.scan(/.*.rb/).join(' ')
system("rubocop --display-cop-names -c .rubocop.yml #{changed_files}")
