#!/bin/sh

# functions
printUsage() {
    echo "Description:"
    echo "  Applies the active theme in '$HOME/.config/themes/active' to config files"
    echo "  wich do not depend on .css files. Which config files get edited is dependant on"
    echo "  the configuration in '$HOME/.config/theme-applier/theme-applier.conf'"
    echo
    echo "Usage:"
    echo "  theme-applier.sh [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h  --help      Show this help message"
}

# read first two and last two colors from the color hex file
color0Hex=$(head -n 1 "$HOME/.config/themes/active/colors_hex.txt" | cut -c 2)
color1Hex=$(head -n 2 "$HOME/.config/themes/active/colors_hex.txt" | cut -c 2)
color2Hex=$(tail -n 3 "$HOME/.config/themes/active/colors_hex.txt" | cut -c 2)
color3Hex=$(tail -n 2 "$HOME/.config/themes/active/colors_hex.txt" | cut -c 2)
color4Hex=$(tail -n 1 "$HOME/.config/themes/active/colors_hex.txt" | cut -c 2)

color0ShRgb="\\e\[38;2;$(head -n 1 "$HOME/.config/themes/active/colors_rgb.txt" | cut -c 2 | sed "s/ /;/g")"
color1ShRgb="\\e\[38;2;$(head -n 2 "$HOME/.config/themes/active/colors_rgb.txt" | cut -c 2 | sed "s/ /;/g")"
color2ShRgb="\\e\[38;2;$(tail -n 3 "$HOME/.config/themes/active/colors_rgb.txt" | cut -c 2 | sed "s/ /;/g")"
color3ShRgb="\\e\[38;2;$(tail -n 2 "$HOME/.config/themes/active/colors_rgb.txt" | cut -c 2 | sed "s/ /;/g")"
color4ShRgb="\\e\[38;2;$(tail -n 1 "$HOME/.config/themes/active/colors_rgb.txt" | cut -c 2 | sed "s/ /;/g")"

updateHyprland() {
    while IFS= read -r line; do
        case "$line" in
            col.active_border) 
                newLine="    col.active_border = rgb($color4Hex)"
                sed -e "s/$line/$newLine/" /dir/file > /dir/temp_file ;;
            col.inactive_border)
                newLine="    col.inactive_border = rgb($color1Hex)"
                sed -e "s/$line/$newLine/" /dir/file > /dir/temp_file ;;
            *) ;;
        esac
    done < "$HOME/.config/hypr/hyprland.conf"
}

updateDunst() {
    urgencyNormal=false
    urgencyCritical=false
    while IFS= read -r line; do
        case "$line" in
            frame_color) 
                newLine="    frame_color = \"#$color4Hex\""
                sed -e "s/$line/$newLine/" /dir/file > /dir/temp_file ;;
            background)
                if [ $urgencyCritical ]; then
                    newLine="    background = \"#$color3Hex\""
                elif [ $urgencyNormal ]; then
                    newLine="    background = \"#$color0Hex\""
                else 
                    newLine="    background = \"#$color1Hex\""
                fi
                sed -e "s/$line/$newLine/" /dir/file > /dir/temp_file ;;
            foreground)
                if [ $urgencyCritical ]; then
                    newLine="    foreground = \"#$color3Hex\""
                elif [ $urgencyNormal ]; then
                    newLine="    foreground = \"#$color0Hex\""
                    urgencyCritical=true
                else 
                    newLine="    foreground = \"#$color1Hex\""
                    urgencyNormal=true
                fi
                sed -e "s/$line/$newLine/" /dir/file > /dir/temp_file ;;
            *) ;;
        esac
    done < "$HOME/.config/dunst/dunstrc"
}

editBashRC() {
    while IFS= read -r line; do
        case "$line" in
            "$1")
                newLine="export $1=$2"
                sed -e "s/$line/$newLine/" /tmp/bashrc_original > "/tmp/bashrc_edited" ;;
        esac
    done < "/tmp/bashrc_original"
}

updateBashRC() {
    cp "$HOME/.bashrc" "/tmp/bashrc_original"

    editBashRC "COLOR_USER" "$color4ShRgb"
    editBashRC "COLOR_PATH" "$color3ShRgb"
    editBashRC "COLOR_GIT" "$color2ShRgb"

    mv /tmp/file "$HOME/.bashrc"
}


# check if usage has to be printed
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printUsage
    exit 0
fi

# read which configs to edit from the config file
while IFS= read -r line; do
    case "$line" in
        "update_hyprland=1") updateHyprland ;;
        "update_dunst=1") updateDunst ;;
        "update_bashrc=1") updateBashRC ;;
    esac
done < "$HOME/.config/theme-applier/theme-applier.conf"