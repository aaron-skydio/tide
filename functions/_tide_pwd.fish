function _tide_pwd
    set -l color_dirs (set_color $tide_pwd_color_dirs || echo)
    set -l color_anchors (set_color -o $tide_pwd_color_anchors || echo)
    set -l keep_background_color (set_color normal -b $tide_pwd_bg_color || echo)
    set -l color_truncated_dirs (set_color $tide_pwd_color_truncated_dirs || echo)

    set -l split_pwd (string replace -- $HOME '~' $PWD | string split /)
    set -l split_pwd_for_length $split_pwd
    set -l split_pwd_for_output $split_pwd

    # Anchor first and last directories
    set split_pwd_for_output[1] $color_anchors$split_pwd[1]$keep_background_color$color_dirs
    set split_pwd_for_output[-1] $color_anchors$split_pwd[-1]$keep_background_color$color_dirs

    set -l icon $tide_pwd_icon_dir' '
    if not test -w $PWD
        set icon $tide_pwd_icon_unwritable' '
    else if test $PWD = $HOME
        set icon $tide_pwd_icon_home' '
    end

    set -g pwd_length (string length "$icon"(string join / $split_pwd_for_length))

    i=1 for dir_section in $split_pwd[2..-2]
        set -l parent_dir (string join -- / $split_pwd[1..$i] | string replace '~' $HOME) # Use i from before increment

        set i (math $i + 1)

        # Returns true if any markers exist in dir_section
        if test -z false (string split --max 2 " " -- "-o -e "$parent_dir/$dir_section/$tide_pwd_markers)
            set split_pwd_for_output[$i] $color_anchors$dir_section$keep_background_color$color_dirs
        else if test $pwd_length -gt $dist_btwn_sides
            while set -l truncation_length (math $truncation_length + 1) &&
                    set -l truncated (string sub --length $truncation_length -- $dir_section) &&
                    test $truncated != $dir_section -a (count $parent_dir/$truncated*/) -gt 1
            end
            set split_pwd_for_length[$i] $truncated
            set split_pwd_for_output[$i] $color_truncated_dirs$truncated$keep_background_color$color_dirs
            set pwd_length (string length "$icon"(string join / $split_pwd_for_length)) # Update length
        end
    end

    printf '%s' $color_dirs $icon
    string join -- / $split_pwd_for_output
end
