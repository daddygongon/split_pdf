# frozen_string_literal: true

require "test_helper"
require "minitest/reporters"
require "open3"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class TestSplitPdf < Minitest::Test
  def setup
    @test_env_dir = File.join(__dir__, "..", "test_env")
    Dir.mkdir(@test_env_dir) unless Dir.exist?(@test_env_dir)
    @sample_yaml_path = File.join(@test_env_dir, "sample.yaml")
    File.write(@sample_yaml_path, "sample: value\n") unless File.exist?(@sample_yaml_path)
  end

  def teardown
    File.delete(@sample_yaml_path) if File.exist?(@sample_yaml_path)
    Dir.rmdir(@test_env_dir) if Dir.exist?(@test_env_dir) && Dir.empty?(@test_env_dir)
  end

  def test_that_it_has_a_version_number
    refute_nil ::SplitPdf::VERSION
  end

  def test_puts_sample_yaml_outputs_sample_yaml
    expected_yaml = File.read(@sample_yaml_path)
    stdout, stderr, status = Open3.capture3("bundle exec exe/split_pdf puts_sample_yaml")
    assert_equal expected_yaml, stdout
    assert status.success?, "Process did not exit successfully: #{stderr}"
  end

  def test_sample_yaml_exists_in_test_env
    assert Dir.exist?(@test_env_dir), "test_env directory does not exist"
    assert File.exist?(@sample_yaml_path), "sample.yaml does not exist in test_env directory"
  end
end
