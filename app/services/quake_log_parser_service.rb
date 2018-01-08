require Rails.root.join('lib/quake_log_parser')

class QuakeLogParserService
  attr_reader :log_data

  def initialize(path)
    @log_data = QuakeLog::Parser.parse(path)
  end
end
