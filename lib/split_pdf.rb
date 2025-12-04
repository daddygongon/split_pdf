# frozen_string_literal: true

require_relative "split_pdf/version"
require "thor"

module SplitPdf
  class Error < StandardError; end

  class CLI < Thor
    desc "puts_sample_yaml", "Prints and saves a hc_sample.yaml"
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
      sample_yaml_path = "hc_sample.yaml" #File.expand_path(, __dir__)
      File.write(sample_yaml_path, yaml_data)
      puts yaml_data
    end

    desc "hello", "Prints Hello world."
    def hello
      puts "Hello world."
    end

    desc "split", "Splits the PDF as specified in hc_sample.yaml"
    def split(yaml_path = "hc_sample.yaml")
      split_pdf(yaml_path, with_pages: true)
    end

    desc "split_wo_pages", "Splits pdf, without pages in filename"
    def split_wo_pages(yaml_path = "hc_sample.yaml")
      split_pdf(yaml_path, with_pages: false)
    end
    
    private

    def split_pdf(yaml_path = "hc_sample.yaml", with_pages: true)
      require "yaml"
      require "fileutils"

      # read hc_sample.yaml for mk config
      config = YAML.load_file(yaml_path)
      source_file = config[:source_file] || config["source_file"]
      target_dir = config[:target_dir] || config["target_dir"]
      toc = config[:toc] || config["toc"]

      FileUtils.mkdir_p(target_dir)

      # split pdf with toc
      toc.each do |v|
        init = v[:init] || v["init"]
        fin = v[:fin] || v["fin"]
        pages = fin.nil? || fin.to_s.empty? ? "#{init}" : "#{init}-#{fin}"
        filename_parts = [v[:no] || v["no"], v[:head] || v["head"]]
        filename_parts << pages if with_pages
        o_file = filename_parts.compact.join('_') + ".pdf"
        target = File.join(target_dir, o_file)
        # qpdfコマンドで分割
        system("qpdf --empty --pages #{source_file} #{pages} -- #{target}")
      end
      puts "PDF split#{with_pages ? '' : ' (wo pages)'} completed and saved in #{target_dir}"
    end


  end
end
