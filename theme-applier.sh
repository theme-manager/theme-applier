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
color0=$(head -n 1 "$HOME/.config/themes/active/colors_hex.txt" | cut -c 2)
color1=$(head -n 2 "$HOME/.config/themes/active/colors_hex.txt" | cut -c 2)

color3=$(tail -n 2 "$HOME/.config/themes/active/colors_hex.txt" | cut -c 2)
color4=$(tail -n 1 "$HOME/.config/themes/active/colors_hex.txt" | cut -c 2)

updateHyprland() {
    while IFS= read -r line; do
        case "$line" in
            col.active_border) 
                newLine="    col.active_border = rgb($color4)"
                sed -e "s/$line/$newLine/" /dir/file > /dir/temp_file ;;
            col.inactive_border)
                newLine="    col.inactive_border = rgb($color1)"
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
                newLine="    frame_color = \"#$color4\""
                sed -e "s/$line/$newLine/" /dir/file > /dir/temp_file ;;
            background)
                if [ $urgencyCritical ]; then
                    newLine="    background = \"#$color3\""
                elif [ $urgencyNormal ]; then
                    newLine="    background = \"#$color0\""
                else 
                    newLine="    background = \"#$color1\""
                fi
                sed -e "s/$line/$newLine/" /dir/file > /dir/temp_file ;;
            foreground)
                if [ $urgencyCritical ]; then
                    newLine="    foreground = \"#$color3\""
                elif [ $urgencyNormal ]; then
                    newLine="    foreground = \"#$color0\""
                    urgencyCritical=true
                else 
                    newLine="    foreground = \"#$color1\""
                    urgencyNormal=true
                fi
                sed -e "s/$line/$newLine/" /dir/file > /dir/temp_file ;;
            *) ;;
        esac
    done < "$HOME/.config/dunst/dunstrc"
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
        *) ;;
    esac
done < "$HOME/.config/theme-applier/theme-applier.conf"