# frozen_string_literal: true

require "test_helper"
require "minitest/reporters"
require "open3"
require "yaml"
require "colorize"
require "fileutils"

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

    # ここで puts_sample_yaml 相当の処理を実行
    exe_path = File.expand_path("../exe/split_pdf", __dir__)
    Dir.chdir(@test_env_dir) do
      comm = "bundle exec #{exe_path} puts_sample_yaml"
      stdout, stderr, status = Open3.capture3(comm)
      raise "puts_sample_yaml failed: #{stderr}" unless status.success?
    end
  end

  def teardown
    #File.delete(@hc_array_yaml_path) if File.exist?(@hc_array_yaml_path)
    #Dir.rmdir(@test_env_dir) if Dir.exist?(@test_env_dir) && Dir.empty?(@test_env_dir)
  end

  def test_that_it_has_a_version_number
    refute_nil ::SplitPdf::VERSION
  end

  def test_puts_sample_yaml
    require 'colorize'
    p exe_path = File.expand_path("../exe/split_pdf", __dir__)
    Dir.chdir(@test_env_dir) do
      p comm = "bundle exec #{exe_path} puts_sample_yaml"
      stdout, stderr, status = Open3.capture3(comm)
#      puts stdout.green
#      puts stderr.red
      assert status.success?,
             "Process did not exit successfully: #{stderr}"
      p hc_sample_yaml_path = File.join(@test_env_dir,
                                        "hc_sample.yaml")
      assert File.exist?(hc_sample_yaml_path),
             "hc_sample.yaml does not exist"
      assert_equal YAML.load_file(@hc_array_yaml_path),
                   YAML.load_file(hc_sample_yaml_path)
    end
  end

  def test_sample_yaml_exists_in_test_env
    assert Dir.exist?(@test_env_dir), "test_env directory does not exist"
    assert File.exist?(@hc_array_yaml_path), "hc_array.yaml does not exist in test_env directory"
  end

  def test_split_creates_split_files
    src_pdf = File.expand_path("./linux_basic.pdf", __dir__)
    dest_pdf = File.join(@test_env_dir, "linux_basic.pdf")
    FileUtils.cp(src_pdf, dest_pdf)

    # split_pdfコマンド実行
    exe_path = File.expand_path("../exe/split_pdf", __dir__)
    comm = "bundle exec #{exe_path} split"
    Dir.chdir(@test_env_dir) do
      stdout, stderr, status = Open3.capture3(comm)
      puts stdout.green
      puts stderr.red

      assert status.success?, "PDF split failed: #{stderr}"

      # 分割先ディレクトリ
      split_dir = File.join(@test_env_dir, "linux_basic")
      assert Dir.exist?(split_dir), "Split directory not created"

      # 分割されたPDFファイル名を個別に確認
      expected_files = [
        "s1_command_2.pdf",
        "s1_line_edit_7-7.pdf",
        "title_1.pdf"
      ]
      expected_files.each do |fname|
        assert File.exist?(File.join(split_dir, fname)), 
        "#{fname} does not exist in split directory"
      end
    end
  end

  def test_split_wo_pages_creates_split_files_wo_pages
    src_pdf = File.expand_path("./linux_basic.pdf", __dir__)
    dest_pdf = File.join(@test_env_dir, "linux_basic.pdf")
    FileUtils.cp(src_pdf, dest_pdf)

    # split_pdf_wo_pagesコマンド実行
    # split_pdfコマンド実行
    exe_path = File.expand_path("../exe/split_pdf", __dir__)
    comm = "bundle exec #{exe_path} split_wo_pages"
    Dir.chdir(@test_env_dir) do
      stdout, stderr, status = Open3.capture3(comm)
      puts stdout.green
      puts stderr.red

      assert status.success?, "PDF split (wo pages) failed: #{stderr}"

      # 分割先ディレクトリ
      split_dir = File.join(@test_env_dir, "linux_basic")
      assert Dir.exist?(split_dir), "Split directory not created"

      # 分割されたPDFファイル名を個別に確認
      expected_files = [
        "s1_command.pdf",
        "s1_line_edit.pdf",
        "title.pdf"
      ]
      expected_files.each do |fname|
        assert File.exist?(File.join(split_dir, fname)),
        "#{fname} does not exist in split directory"
      end
    end
  end
end
