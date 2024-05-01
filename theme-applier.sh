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
    echo "  -h  --help              Show this help message"
    echo "  -a  --auto  <on/off>    Automatically apply the current theme on system startup"
    echo "      --auto-update       Flag for automatic execution of this script."
    echo "                          It checks the auto_update variable in the config and updates, if set to 1"   
}

colorHexFile="$HOME/.config/themes/active/colors/colors-hex.txt"
colorShRgbFile="$HOME/.config/themes/active/colors/colors-rgb.txt"

# removing all empty lines from the color files
sed -i '/^$/d' "$colorHexFile"
sed -i '/^$/d' "$colorShRgbFile"

# read first two and last two colors from the color hex file
color0Hex=$(head -n 1 "$colorHexFile" | sed 's/#//g')
color1Hex=$(head -n 2 "$colorHexFile" | tail -n 1 | sed 's/#//g')
color2Hex=$(tail -n 3 "$colorHexFile" | head -n 1 | sed 's/#//g')
color3Hex=$(tail -n 2 "$colorHexFile" | head -n 1 | sed 's/#//g')
color4Hex=$(tail -n 1 "$colorHexFile" | sed 's/#//g')

color0ShRgb="e[38;2;$(head -n 1 "$colorShRgbFile" | sed "s/ /;/g")m"
color1ShRgb="e[38;2;$(head -n 2 "$colorShRgbFile" | sed "s/ /;/g" | tail -n 1)m"
color2ShRgb="e[38;2;$(tail -n 3 "$colorShRgbFile" | sed "s/ /;/g" | head -n 1)m"
color3ShRgb="e[38;2;$(tail -n 2 "$colorShRgbFile" | sed "s/ /;/g" | head -n 1)m"
color4ShRgb="e[38;2;$(tail -n 1 "$colorShRgbFile" | sed "s/ /;/g")m"

hyprlandPath="$HOME/.config/hypr/hyprland.conf"
bashrcPath="$HOME/.bashrc"
dunstPath="$HOME/.config/dunst/dunstrc"

printColors() {
    echo "Hex Colors:"
    echo "    $color0Hex"
    echo "    $color1Hex"
    echo "    $color2Hex"
    echo "    $color3Hex"
    echo "    $color4Hex"
    echo
    echo "Sh RGB Colors:"
    echo "    $color0ShRgb"
    echo "    $color1ShRgb"
    echo "    $color2ShRgb"
    echo "    $color3ShRgb"
    echo "    $color4ShRgb"
}

updateHyprland() {
    echo updating the hyprland theme...
    cp "$hyprlandPath" /tmp/hypr.conf
    while IFS= read -r line; do
        case "$line" in
            *" col.active_border"*) 
                newLine="    col.active_border = rgb($color4Hex)"
                sed -i "s/$line/$newLine/g" /tmp/hypr.conf ;;
            *" col.inactive_border"*)
                newLine="    col.inactive_border = rgb($color1Hex)"
                sed -i "s/$line/$newLine/g" /tmp/hypr.conf ;;
        esac
    done < "/tmp/hypr.conf"

    mv /tmp/hypr.conf "$hyprlandPath"
}

updateDunst() {
    echo updating the dunst theme...
    cp "$dunstPath" /tmp/dunst.conf
    while IFS= read -r line; do
        case "$line" in
            "    frame_color"*) 
                newLine="    frame_color = \"#$color4Hex\""
                sed -i "s/$line/$newLine/g" /tmp/dunst.conf ;;
            "    background"*)
                case "$line" in
                    *" #0"*) newLine="    background = \"#$color1Hex\" #0";;
                    *" #1"*) newLine="    background = \"#$color0Hex\" #1";;
                    *" #2"*) newLine="    background = \"#$color3Hex\" #2";;
                esac
                sed -i "s/$line/$newLine/g" /tmp/dunst.conf ;;
            "    foreground"*)
                case "$line" in
                    *" #0"*) newLine="    foreground = \"#$color4Hex\" #0";;
                    *" #1"*) newLine="    foreground = \"#$color4Hex\" #1";;
                    *" #2"*) newLine="    foreground = \"#$color4Hex\" #2";;
                esac
                sed -i "s/$line/$newLine/g" /tmp/dunst.conf ;;
        esac
    done < "/tmp/dunst.conf"

    mv /tmp/dunst.conf "$dunstPath"
    killall dunst && dunst &
}

# Heh, it aint stupid if it works!
editBashRC() {
    lineNum=$(grep -n "export $1" "/tmp/bashrc_original" | cut -d ':' -f 1)
    newLine="export $1='\\${2}'"
    
    sed -i "${lineNum}"',$d' /tmp/bashrc_edited
    echo "$newLine" >> /tmp/bashrc_edited
    lineNum=$((lineNum+1))
    tail -n "+$lineNum" /tmp/bashrc_original >> /tmp/bashrc_edited
}

updateBashRC() {
    echo updating the bashrc theme...
    cp "$bashrcPath" "/tmp/bashrc_original"
    cp "$bashrcPath" /tmp/bashrc_edited

    editBashRC "COLOR_USER" "${color4ShRgb}"
    editBashRC "COLOR_PATH" "${color3ShRgb}"
    editBashRC "COLOR_GIT" "${color2ShRgb}"

    rm /tmp/bashrc_original
    mv /tmp/bashrc_edited "$bashrcPath"
}

updateQT() {
    echo updating the qt theme...
    echo Not yet implemented
}

editApplierConfig() {
    if [ "$1" != "on" ]; then
        newLine="auto_update=1"
    elif [ "$1" != "off" ]; then
        newLine="auto_update=0"
    else
        echo Wrong format on auto option: "$1"
        exit 2
    fi

    cp "$HOME/.config/theme-applier/theme-applier.conf" /tmp/theme-applier.conf
    lineNum=$(grep -n "auto_update" "$HOME/.config/theme-applier/theme-applier.conf" | cut -d ':' -f 1)
    sed -i "${lineNum}"',$d' "$HOME/.config/theme-applier/theme-applier.conf"
    echo "$newLine" >> "$HOME/.config/theme-applier/theme-applier.conf"
    lineNum=$((lineNum+1))
    tail -n "+$lineNum" "/tmp/theme-applier.conf" >> "$HOME/.config/theme-applier/theme-applier.conf"
}

# check if usage has to be printed
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printUsage
    exit 0
fi; if [ "$1" = "-a" ] || [ "$1" = "--auto" ]; then
    editApplierConfig "$2"
fi; if [ "$1" = "--auto-update" ]; then
    # Exits the program if in the configuration auto_update is not enabled.
    doAutoUpdate=$(grep -n "auto_update" "$HOME/.config/theme-applier/theme-applier.conf" | cut -d ':' -f 2 | cut -d "=" -f 2)
    if [ "$doAutoUpdate" != "1" ]; then
        exit 0
    fi
fi

# read which configs to edit from the config file
while IFS= read -r line; do
    case "$line" in
        "update_hyprland=1") updateHyprland ;;
        "update_dunst=1") updateDunst ;;
        "update_bashrc=1") updateBashRC ;;
        "update_qt=1") updateQT ;;
    esac
done < "$HOME/.config/theme-applier/theme-applier.conf"

#killall hyprpaper
#hyprpaper &