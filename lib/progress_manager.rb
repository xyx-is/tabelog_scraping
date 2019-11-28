require "json"

class ProgressManager
  def initialize(progress_file_name)
    @processes = []
    @progress_file_name = progress_file_name
  end

  def add_process(process_name, &block)
    @processes.push([process_name.to_s, block])
  end

  def execute(execute_args)
    @progress = load_progress_from_file()

    @processes.each do |process_name, block|
      if @progress[process_name]
        # skip this process
      else
        $stdout.print "START PROCESS #{process_name}\n"
        block[execute_args]
        @progress[process_name] = true
        save_progress_to_file()
        $stdout.print "END PROCESS #{process_name}\n"
      end
    end
  end

  def serialize(progress)
    JSON.generate(progress)
  end

  def save_progress_to_file()
    File.write(@progress_file_name, serialize(@progress))
  end

  def deserialize_from(str)
    JSON.parse(str)
  end

  def load_progress_from_file()
    if File.exists?(@progress_file_name)
      deserialize_from(File.read(@progress_file_name))
    else
      {}
    end
  end
end
