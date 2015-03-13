class Program
    OVERRIDE_PATH = ''
    SRC_DIRS = [
        'C:\Code\ecs160-linux-java\master'
    ]
    FILE_MASK = '**/*.java'
    REGEXES = {
        /(SInt2)/ => 'Vector2',
        /(SDouble2)/ => 'Vector2',
        /(\.DX)/ => '.x',
        /(\.DY)/ => '.y',
        /(\.DZ)/ => '.z',
        /\.push_back/ => '.add',
        /\.front\(\)/ => '.get(0)',
        /\.pop_front\(\)/ => '.remove(0)',
        /std\.deque/ => 'LinkedList',
        /java\.util\./ => '',
        /IntegerSquareRoot\((.*)\.Magnitude\(\)/ => 'IntegerSquareRoot((int)MathUtil.magnitude(\1)',
        /(.*)\.copyFrom\((.*)\)/ => '\1 = new Vector2(\2)',
        /(^\s*case\s+)(.*\.)(.*)/ => '\1\3',
        /\.Vector2Position\(\)/ => ''
    }

    def initialize
        @total_lines_modified = 0
    end

    def run
        if not OVERRIDE_PATH.nil? and OVERRIDE_PATH != ''
            process OVERRIDE_PATH
            exit(0)
        end
        SRC_DIRS.each do |src_dir|
            Dir.chdir src_dir
            num_files = 0
            Dir.glob(FILE_MASK) do |file|
                path = File.join(src_dir, file)
                num_files += 1
                process path
            end
            puts "Modified #{@total_lines_modified} lines total in #{num_files} files in #{src_dir} with file mask '#{FILE_MASK}'"
        end
    end

    def process(file)
        file_contents = File.open(file, "r").readlines
        new_file_contents = regex_replace file, file_contents
        File.open(file, "w") { |f| f.puts(new_file_contents) }
    end

    def regex_replace(file, file_contents)
        num_modifications = 0
        file_contents.each_with_index do |line, index|
            REGEXES.each_key do |regex|
                index_of_match = line =~ regex
                if not index_of_match.nil?
                    puts "\t Line #{index + 1} (#{regex.source} => #{REGEXES[regex].to_s}): #{line}"
                    line = line.gsub(regex, REGEXES[regex])
                    file_contents[index] = line
                    num_modifications += 1
                end
            end
        end
        @total_lines_modified += num_modifications;
        if num_modifications > 0
            puts "Processing #{file}."
            puts "Modified #{num_modifications} lines in '#{file}'."
            puts
        end
        file_contents
    end
end

begin
    Program.new.run()
rescue StandardError => e
    puts "Error: #{e}"
end