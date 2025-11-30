# frozen_string_literal: true

require_relative "split_pdf/version"
require "thor"

module SplitPdf
  class Error < StandardError; end

  class CLI < Thor
    desc "puts_sample_yaml", "Prints the contents of sample.yaml"
    def puts_sample_yaml
      sample_yaml_path = File.expand_path("../../test_env/sample.yaml", __dir__)
      if File.exist?(sample_yaml_path)
        puts File.read(sample_yaml_path)
      else
        puts "sample.yaml not found in test_env directory."
        exit 1
      end
    end

    desc "hello", "Prints Hello world."
    def hello
      puts "Hello world."
    end
  end
end
