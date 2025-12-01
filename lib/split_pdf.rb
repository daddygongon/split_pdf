# frozen_string_literal: true

require_relative "split_pdf/version"
require "thor"

module SplitPdf
  class Error < StandardError; end

  class CLI < Thor
    desc "puts_sample_yaml", "Prints and saves a sample hc_array.yaml as sample.yaml in test_env"
    def puts_sample_yaml
      require "yaml"
      hc_array = {
        source_file: './linux_basic.pdf',
        target_dir: './linux_basic',
        toc: [
          {no: nil, init: 1,  fin: nil,  head: 'title'},
          {no: 's1',init: 2,  fin: nil, head: 'command'},
          {no: 's1',init: 7, fin: 7, head: 'line_edit'},
        ]
      }
      yaml_data = YAML.dump(hc_array)
      sample_yaml_path = File.expand_path("../test_env/sample.yaml", __dir__)
      File.write(sample_yaml_path, yaml_data)
      puts yaml_data
    end

    desc "hello", "Prints Hello world."
    def hello
      puts "Hello world."
    end
  end
end
