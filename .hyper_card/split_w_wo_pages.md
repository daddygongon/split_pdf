daddygongon: splitとsplit_wo_pagesには多くの共通点があります．これをmethodに切り出して，optionでwithとwithoutを切り替えるようにrefactoringしてください．

GitHub Copilot: `split`と`split_wo_pages`の共通処理をメソッドに切り出し、ファイル名にページ情報を含めるかどうかをオプションで切り替えられるようにリファクタリングする例です。

````ruby
# ...existing code...

    private

    def split_pdf(yaml_path = "hc_sample.yaml", with_pages: true)
      require "yaml"
      require "fileutils"

      config = YAML.load_file(yaml_path)
      source_file = config[:source_file] || config["source_file"]
      target_dir = config[:target_dir] || config["target_dir"]
      toc = config[:toc] || config["toc"]

      FileUtils.mkdir_p(target_dir)

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

    desc "split", "Splits the PDF as specified in hc_sample.yaml"
    def split(yaml_path = "hc_sample.yaml")
      split_pdf(yaml_path, with_pages: true)
    end

    desc "split_wo_pages", "Splits the PDF as specified in hc_sample.yaml, without pages in filename"
    def split_wo_pages(yaml_path = "hc_sample.yaml")
      split_pdf(yaml_path, with_pages: false)
    end

# ...existing code...
````

このリファクタリングにより、`split_pdf`メソッドで共通処理をまとめ、`with_pages`オプションでファイル名のページ情報の有無を切り替えています。

daddygongon:  bundle exec rake test
(in /Users/bob/git_hub/split_pdf)
/Users/bob/git_hub/split_pdf/test/test_split_pdf.rb:41: warning: assigned but unused variable - stdout
/Users/bob/git_hub/split_pdf/test/test_split_pdf.rb:60: warning: assigned but unused variable - stdout
Started with run options --seed 1724

TestSplitPdf

Could not find command "split_wo_pages".
Deprecation warning: Thor exit with status 0 on errors. To keep this behavior, you must define `exit_on_failure?` in `SplitPdf::CLI`
You can silence deprecations warning by setting the environment variable THOR_SILENCE_DEPRECATION.

  test_split_wo_pages_creates_split_files_wo_pages                PASS (0.15s)
  test_that_it_has_a_version_number                               PASS (0.08s)
"/Users/bob/git_hub/split_pdf/exe/split_pdf"
"bundle exec /Users/bob/git_hub/split_pdf/exe/split_pdf puts_sample_yaml"
"/Users/bob/git_hub/split_pdf/test/test_env/hc_sample.yaml"
  test_puts_sample_yaml                                           PASS (0.16s)
  test_sample_yaml_exists_in_test_env                             PASS (0.08s)

Could not find command "split".
Deprecation warning: Thor exit with status 0 on errors. To keep this behavior, you must define `exit_on_failure?` in `SplitPdf::CLI`
You can silence deprecations warning by setting the environment variable THOR_SILENCE_DEPRECATION.

  test_split_creates_split_files                                  PASS (0.15s)

とのエラー．

GitHub Copilot: Thorコマンドが「Could not find command "split"」「Could not find command "split_wo_pages"」と出る原因は、`split`と`split_wo_pages`メソッドが`private`の下に定義されているためです。Thorは`private`メソッドをコマンドとして認識しません。

**解決方法**  
`private`の宣言より下にコマンドメソッド（`split`, `split_wo_pages`）を置かないようにしてください。  
`split_pdf`だけを`private`にし、コマンドメソッドは`public`のままにします。

修正例：

````ruby
# ...existing code...

    desc "split", "Splits the PDF as specified in hc_sample.yaml"
    def split(yaml_path = "hc_sample.yaml")
      split_pdf(yaml_path, with_pages: true)
    end

    desc "split_wo_pages", "Splits the PDF as specified in hc_sample.yaml, without pages in filename"
    def split_wo_pages(yaml_path = "hc_sample.yaml")
      split_pdf(yaml_path, with_pages: false)
    end

    private

    def split_pdf(yaml_path = "hc_sample.yaml", with_pages: true)
      require "yaml"
      require "fileutils"
      # ...existing code...
    end

# ...existing code...
````

このように`private`の宣言より上にコマンドメソッドを移動してください。  
これでThorがコマンドを認識し、テストも通るはずです。