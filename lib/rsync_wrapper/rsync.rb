class Rsync
  def initialize **opts
    @dirs = {}
    [:src_dir, :dest_dir].each do |k|
      raise ArgumentError, "#{k} is required" unless opts[k]
      @dirs[k] = opts[k]
    end
    @inclusions = opts[:include_extensions] ? opts[:include_extensions].map{|ext| "*.#{ext}"} : []
    @exclusions = opts[:exclusions] || []
    if opts[:subdirs_only]
      @inclusions << '*/' # include subdirectories
      @exclusions << '*'
    end
    @logfile = if opts[:log_dir]
      File.join(opts[:log_dir], "rsync-#{SecureRandom.uuid}.log")
    elsif opts[:logfile]
      opts[:logfile]
    else
      File.join(Dir.pwd, "rsync-#{SecureRandom.uuid}.log")
    end

    @optional_arguments = [
      :bwlimit,
      # TODO: add rsync's other arguments that wouldn't interfere with the design of this gem https://linux.die.net/man/1/rsync
    ].map{|arg| opts[arg] ? [arg, opts[arg]] : nil}.compact.to_h
  end

  def sync! &block
    exec_rsync
    parse_logfile &block
  end

  private

  def exec_rsync
    rsync_opts = ['-ri', "--log-file '#{@logfile}'", '--size-only', '--prune-empty-dirs']
    rsync_opts += @inclusions.map{|inc| "--include '#{inc}'"}
    rsync_opts += @exclusions.map{|exc| "--exclude '#{exc}'"}

    rsync_opts += @optional_arguments.map{|k,v| "--#{k}=#{v}"}

    cmd = "rsync #{rsync_opts.join(' ')} \"#{@dirs[:src_dir]}\" \"#{@dirs[:dest_dir]}\" > /dev/null 2>&1"
    `#{cmd}`
  end

  def parse_logfile
    base_dir = File.basename @dirs[:src_dir]
    File.open(@logfile, 'r') do |f|
      f.each_line do |line|
        line_arr = line.split(/ /)
        next unless line_arr.length > 4
        #http://andreafrancia.it/2010/03/understanding-the-output-of-rsync-itemize-changes.html
        changes = line_arr[3]
        next unless changes.start_with?('>f') # file transfered to local
        file_path = line_arr[4..-1].join(' ').strip
        next unless file_path.start_with?(base_dir)

        if block_given?
          if changes.start_with?('>f+++')
            yield file_path, true
          elsif changes[3] == 's'
            yield file_path, false
          end
        end
      end
    end

    File.delete @logfile
  end
end
