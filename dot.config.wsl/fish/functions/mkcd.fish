function mkcd
    if test (count $argv) -eq 0
        echo "mkcd: missing directory name"
        return 1
    end

    mkdir -p $argv[1] && cd $argv[1]
end
