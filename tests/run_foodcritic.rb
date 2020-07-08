# Copyright (c) Facebook, Inc. and its affiliates.
#
# rubocop:disable Metrics/BlockLength
RSpec.describe 'Check that the cookbooks changed pass foodcritic.' do
  before do
    # Foodcritic rules to exclude.
    @exclude_rules = %w[
      FC014
      FC017
      FC024
      FC059
      FC064
      FC065
      FC066
      FC067
      FC069
      FC071
      FC078
    ]
    @exclude_rules = @exclude_rules.join(' -t ~')

    # Diff-tree of only files in cookbooks
    current_sha = 'origin/master..HEAD'
    options = '--no-commit-id --diff-filter=ACMRT --name-only'
    grep_cookbooks = 'grep itchef/cookbooks'
    @files =
      `git diff-tree #{options} -r #{current_sha} | #{grep_cookbooks}`

    @files = @files.split("\n")

    @cookbooks = []
    @files.each do |file|
      dir = 'itchef/cookbooks/' + file.split('/')[2]
      @cookbooks << dir
    end
    @cookbooks = @cookbooks.uniq.join(' ')
  end

  it 'runs foodcritic on changed cookbooks' do
    if @cookbooks.empty?
      puts 'Foodcritic not performed. No cookbooks changed.'
    else
      puts 'Running foodcritic for changed cookbooks: ' +
           @cookbooks
      puts 'bundle exec foodcritic -f any -t ' +
           "~#{@exclude_rules} #{@cookbooks}"
      args = 'bundle exec foodcritic -f any -t ' +
             "~#{@exclude_rules} #{@cookbooks}"
      result = system args
      expect(result).to be(true)
    end
  end
end
# rubocop:enable Metrics/BlockLength
