rsync_wrapper
==============

`rsync_wrapper` is a simple gem that provides a ruby wrapper to the [rsync](http://linux.die.net/man/1/rsync) file copying tool.


Requirements and Dependencies
-----------------------------

Developed/Tested with Ruby version 2.3, but it should work with any version >= 1.9.  This gem will only work on an *NIX (OSX/Linux) based operating system that has `rsync`.


Installation
-----------------------------

Add to your `Gemfile`:

```ruby
gem 'rsync_wrapper'
```


Usage
-----------------------------

First, instantiate an instance of `Rsync`:

```ruby
rsync = Rsync.new(**options)
```

The constructor accepts the following named arguments:

| Argument Name         | Required? | Object Type | Description                                                                                                                                                                                                                                   |
|-----------------------|-----------|-------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `:src_dir`            | Required  | `String`    | An absolute path representing the source directory to have `rsync` copy. e.g., `"/Users/seanhuber/Documents/my_pdfs"`                                                                                                                         |
| `:dest_dir`           | Required  | `String`    | An absolute path representing the destination directory that `rsync` will copy the `:src_dir` to.                                                                                                                                             |
| `:include_extensions` | Optional  | `Array`     | An array of symbols or strings for each file extension `rsync` should include, e.g., `[:doc, :docx, :pdf]`                                                                                                                                    |
| `:subdirs_only`       | Optional  | `Boolean`   | An option to have `rsync` only sync files that are in subfolders of `:src_dir`. Defaults to `false`.                                                                                                                                          |
| `:log_dir`            | Optional  | `String`    | `rsync_wrapper` has `rsync` pipe its results into a logfile so that the ruby code can then parse this file (and then deletes it). This option should be set to the absolute path of the directory where the temporary logfile will be stored. |
| `:logfile`            | Optional  | `String`    | If the `:log_dir` is not specified, you can provide an explicit path for `rsync_wrapper`'s temporary logfile.                                                                                                                                 |
| `:bwlimit`|Optional|`Integer`|From rsync's man pages: This option allows you to specify a maximum transfer rate in kilobytes per second. This option is most effective when using rsync with large files (several megabytes and up). Due to the nature of rsync transfers, blocks of data are sent, then if rsync determines the transfer was too fast, it will wait before sending the next data block. The result is an average transfer rate equaling the specified limit. A value of zero specifies no limit.|

To execute `rsync`, invoke the `sync!` method which accepts a block with 2 parameters:

| Argument Index | Object Type | Description                                                                             |
|----------------|-------------|-----------------------------------------------------------------------------------------|
| `0`            | `String`    | The relative path (relative to `:dest_dir` from above) of the copied file.              |
| `1`            | `Boolean`   | `true` if the copied file is a new file. `false` if the copied file is an updated file. |

Example:

```ruby
source_directory = '/path/of/directory/you/want/to/sync'
destination_directory = '/path/of/directory/to/sync/to'

rsync = Rsync.new(src_dir: source_directory, dest_dir: destination_directory)

rsync.sync! do |file_path, new_file|
  puts "Full Path: #{File.join(destination_directory, file_path)}"
  puts "The relative path of the new file is: #{file_path}"
  if new_file
    puts "This is a brand new file."
  else
    puts "This is an updated file."
  end
end
```


License
-----------------------------

MIT-LICENSE.
