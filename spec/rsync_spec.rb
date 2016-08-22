require 'spec_helper'

describe Rsync do
  it 'executes rsync' do
    rsync = Rsync.new(
      src_dir: File.join(FileUtils.pwd, 'spec', 'test_src_dir'),
      dest_dir: File.join(FileUtils.pwd, 'spec', 'test_dest_dir'),
      include_extenstions: [:doc, :docx, :pdf],
      subdirs_only: true,
      logfile: File.join(FileUtils.pwd, 'spec', 'dummy_rsync_output.log')
    )
    expect(rsync).to receive(:`).with("rsync -ri --log-file '/Users/seanhuber/Rails Apps/rsync_wrapper/spec/dummy_rsync_output.log' --size-only --prune-empty-dirs --include '*.doc' --include '*.docx' --include '*.pdf' --include '*/' --exclude '*' \"/Users/seanhuber/Rails Apps/rsync_wrapper/spec/test_src_dir\" \"/Users/seanhuber/Rails Apps/rsync_wrapper/spec/test_dest_dir\" > /dev/null 2>&1")
    expect(rsync).to receive(:parse_logfile).and_return(nil)
    rsync.sync!
  end

  it 'parses an rsync logfile' do
    rsync = Rsync.new(
      src_dir: File.join(FileUtils.pwd, 'spec', 'test_src_dir'),
      dest_dir: File.join(FileUtils.pwd, 'spec', 'test_dest_dir'),
      include_extenstions: [:doc, :docx, :pdf],
      subdirs_only: true,
      logfile: File.join(FileUtils.pwd, 'spec', 'dummy_rsync_output.log')
    )
    allow(rsync).to receive(:`)
    expected_results = [
      ["my_source_dir/file_one.pdf", false],
      ["my_source_dir/second_file.doc", true]
    ]
    idx = 0
    rsync.sync! do |file_path, new_file|
      expect([file_path, new_file]).to eql(expected_results[idx])
      idx += 1
    end
  end

  it 'syncs two directories' do
    src_dir = File.join(FileUtils.pwd, 'spec', 'test_src_dir')
    dest_dir = File.join(FileUtils.pwd, 'spec', 'test_dest_dir')

    output_dir = FileUtils.mkdir_p File.join(dest_dir, File.basename(src_dir))
    FileUtils.touch File.join(output_dir, 'first_file.txt')

    logfile = File.join(FileUtils.pwd, 'spec', 'actual_sync.log')
    File.delete(logfile) if File.file?(logfile)

    rsync = Rsync.new(
      src_dir: src_dir,
      dest_dir: dest_dir,
      include_extenstions: [:txt],
      subdirs_only: true,
      logfile: logfile
    )

    expected_results = [
      ['test_src_dir/first_file.txt', false],
      ['test_src_dir/second_file.txt', true]
    ]
    idx = 0

    rsync.sync! do |file_path, new_file|
      expect([file_path, new_file]).to eql(expected_results[idx])
      idx += 1
    end

    FileUtils.rm_rf dest_dir
  end
end
