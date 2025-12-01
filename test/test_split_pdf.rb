# frozen_string_literal: true

require "test_helper"
require "minitest/reporters"
require "open3"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class TestSplitPdf < Minitest::Test
  def setup
    @test_env_dir = File.join(__dir__, "test_env")
    Dir.mkdir(@test_env_dir) unless Dir.exist?(@test_env_dir)
    @hc_array_yaml_path = File.join(@test_env_dir, "hc_array.yaml")
    @expected_yaml = <<~YAML
      ---
      :source_file: ./linux_basic.pdf
      :target_dir: ./linux_basic
      :toc:
      - :no: 
        :init: 1
        :fin: 
        :head: title
      - :no: s1
        :init: 2
        :fin: 
        :head: command
      - :no: s1
        :init: 7
        :fin: 7
        :head: line_edit
    YAML
    File.write(@hc_array_yaml_path, @expected_yaml) # ←毎回上書き
  end

  def teardown
    File.delete(@hc_array_yaml_path) if File.exist?(@hc_array_yaml_path)
    Dir.rmdir(@test_env_dir) if Dir.exist?(@test_env_dir) && Dir.empty?(@test_env_dir)
  end

  def test_that_it_has_a_version_number
    refute_nil ::SplitPdf::VERSION
  end

  def test_puts_sample_yaml
    p exe_path = File.expand_path("../exe/split_pdf", __dir__)
    require "yaml"
    Dir.chdir(@test_env_dir) do
      __stdout__, stderr, status = Open3.capture3("bundle exec #{exe_path} puts_sample_yaml")
      assert status.success?, "Process did not exit successfully: #{stderr}"
      p hc_sample_yaml_path = File.join(@test_env_dir, "hc_sample.yaml")
      assert File.exist?(hc_sample_yaml_path), "hc_sample.yaml does not exist"
      assert_equal YAML.load_file(@hc_array_yaml_path), YAML.load_file(hc_sample_yaml_path)
    end
  end

  def test_sample_yaml_exists_in_test_env
    assert Dir.exist?(@test_env_dir), "test_env directory does not exist"
    assert File.exist?(@hc_array_yaml_path), "hc_array.yaml does not exist in test_env directory"
  end
end
