require 'optparse'

module RubyWolf
  class CLI
    attr_reader :app, :server, :configs

    def initialize(args)
      @args = args
      @configs = RubyWolf::Configuration.new
      @app_root = `pwd`.to_s.strip
    end

    def run
      parse_options
      set_environment

      raise 'Rack file not found' unless File.exist?(rack_file)

      @server = RubyWolf::Server.new(rack_file, configs)
      @server.start
    end

    def parse_options
      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage: ruby_wolf [options]'

        opts.on('-d', '--daemon', 'Demonize this web server to run background') do
          @configs[:daemon] = true
        end

        opts.on('-h HOST', '--port=HOST', 'Binding host') do |arg|
          @configs[:host] = arg
        end

        opts.on('-p PORT', '--port=PORT', 'Port of the program') do |arg|
          @configs[:port] = arg.to_i
        end

        opts.on('-w WORKER', '--worker=WORKER', 'Number of worker processes') do |arg|
          @configs[:worker] = arg.to_i
        end

        opts.on('-e ENVIRONMENT', '--environment=ENVIRONMENT', 'Current environment') do |arg|
          @configs[:environment] = arg
        end

        opts.on('-h', '--help', 'Show the usages') do
          puts opts
          exit
        end
      end

      opt_parser.parse!(@args)
    end

    private

    def rack_file
      "#{@app_root}/config.ru"
    end

    def set_environment
      ENV['RAILS_ENV'] = configs[:environment]
      ENV['RACK_ENV'] = configs[:environment]
    end
  end
end
