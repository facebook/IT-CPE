# Copyright (c) Facebook, Inc. and its affiliates.

RSpec.describe 'Check that the files changed have correct syntax' do
  before do
    current_sha = 'origin/master..HEAD'
    options = '--no-commit-id --diff-filter=ACMRT --name-only'
    grep = 'grep .rb'
    @files =
      `git diff-tree #{options} -r #{current_sha} | #{grep}`
    @files.tr!("\n", ' ')
  end

  it 'runs rubocop on changed ruby files' do
    if @files.empty?
      puts 'Linting not performed. No ruby files changed.'
    else
      puts "Running rubocop for changed files: #{@files}"
      result = system \
        "bundle exec rubocop --config .rubocop.yml #{@files}"
      expect(result).to be(true)
    end
  end
end
