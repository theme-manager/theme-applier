#!/bin/sh

# functions
printUsage() {
    echo "Description:
    Applies the active theme in '$HOME/.config/themes/active' to config files
    wich do not depend on .css files. Which config files get edited is dependant on
    the configuration in '$HOME/.config/theme-applier/theme-applier.conf'
    
Usage:
    theme-applier.sh [OPTIONS]
    
Options:
    -h  --help                      Show this help message
        --auto-update               Flag for automatic execution of this script.
                                    It checks the auto_update variable in the config and updates if it is set to 1
    -a  --apply <variable> ...      Apply theme <variables>:    
                                        h: Applies Hyprland
                                        p: Applies Hyprpaper
                                        d: Applies dunst
                                        w: Applies waybar
                                        b: Applies bashrc
                                        k: Applies kitty
                                        q: Applies qt theme
    -s  --set   <name> <on/off>     Set the variable <name> to <on/off>
                                        <auto>:         Automatically apply the current theme on system startup
                                        <hyprland>:     Determines if hyprland has to be updated when theme is applied
                                        <hyprpaper>:    Determines if hyprpaper (Wallpaper) has to be updated when the theme is applied
                                        <dunst>:        Determines if dunst has to be updated when theme is applied
                                        <waybar>:       Determines if waybar has to be updated when theme is applied
                                        <bash>:         Determines if bashrc has to be updated when theme is applied
                                        <kitty>:        Determines if kitty has to be updated when theme is applied
                                        <qt>:           Determines if qt theme has to be updated when theme is applied"  
}

# error codes
# 0 - success
# 1 - missing argument(s)
# 2 - wrong argument(s)
# 3 - missing dependecy
# 4 - wrong configuration file
# 5 - internal error

colorHexFile="$HOME/.config/theme-manager/themes/active/colors/colors-hex.txt"
colorShRgbFile="$HOME/.config/theme-manager/themes/active/colors/colors-rgb.txt"

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
hyprpaperPath="$HOME/.config/hypr/hyprpaper.conf"
bashrcPath="$HOME/.bashrc"
dunstPath="$HOME/.config/dunst/dunstrc"
kittyPath="$HOME/.config/kitty/kitty.conf"

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
    cp "$hyprlandPath" /tmp/hyprland.conf
    while IFS= read -r line; do
        case "$line" in
            *" col.active_border"*) 
                newLine="    col.active_border = rgb($color4Hex)"
                sed -i "s/$line/$newLine/g" /tmp/hyprland.conf ;;
            *" col.inactive_border"*)
                newLine="    col.inactive_border = rgb($color1Hex)"
                sed -i "s/$line/$newLine/g" /tmp/hyprland.conf ;;
        esac
    done < "/tmp/hyprland.conf"

    mv /tmp/hyprland.conf "$hyprlandPath"
}

updateHyprpaper() {
    echo updating the hyprpaper wallpaper path...
    cp "$hyprpaperPath" /tmp/hyprpaper.conf
    wallpaperPath="$HOME/.config/theme-manager/themes/active/Wallpaper/$(ls "$HOME/.config/theme-manager/themes/active/Wallpaper/")"
    while IFS= read -r line; do
        case "$line" in
            "preload"*) 
                newLine="preload = $wallpaperPath"
                sed -i "s|$line|$newLine|g" /tmp/hyprpaper.conf ;;
            "wallpaper"*)
                newLine="wallpaper = eDP-2, $wallpaperPath"
                sed -i "s|$line|$newLine|g" /tmp/hyprpaper.conf ;;
        esac
    done < "/tmp/hyprpaper.conf"

    mv /tmp/hyprpaper.conf "$hyprpaperPath"

    (killall hyprpaper) 1>/dev/null
    (hyprpaper &) 1>/dev/null
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

updateWaybar() {
    echo rebooting waybar...
    killall waybar
    (waybar &) 1>/dev/null
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
    source "$HOME/.bashrc"
}

editKitty() {
    lines=$(grep -n "$1 #" "/tmp/kitty_original" | grep -v ':#' | cut -d ':' -f 1)
    for lineNum in $lines; do
        newLine="$1 #$2"
        
        sed -i "${lineNum}"',$d' /tmp/kitty_edited
        echo "$newLine" >> /tmp/kitty_edited
        lineNum=$((lineNum+1))
        tail -n "+$lineNum" /tmp/kitty_original >> /tmp/kitty_edited
    done
}

updateKitty() {
    echo updating the kitty theme...
    cp "$kittyPath" /tmp/kitty_original
    cp "$kittyPath" /tmp/kitty_edited
    editKitty "foreground" "$color4Hex"
    cp /tmp/kitty_edited /tmp/kitty_original
    editKitty "background" "$color0Hex"

    cp /tmp/kitty_edited "$kittyPath"
    rm /tmp/kitty_original
    rm /tmp/kitty_edited
}

updateQT() {
    echo updating the qt theme...
    echo Not yet implemented
}

editApplierConfig() {
    case "$1" in
        auto) varName='auto_update' ;;
        hypr) varName='update_hyprland' ;;
        dunst) varName='update_dunst' ;;
        bash) varName='update_bashrc' ;;
        kitty) varName='update_kitty' ;;
        qt) varName='update_qt' ;;
        waybar) varName='update_waybar' ;;
        *) echo Wrong format on option: "$1"; exit 2 ;;
    esac

    if [ "$2" = "on" ]; then
        newLine="$varName=1"
    elif [ "$2" = "off" ]; then
        newLine="$varName=0"
    else
        echo Wrong format on auto option: "$2"
        exit 2
    fi

    cp "$HOME/.config/theme-manager/theme-applier.conf" /tmp/theme-applier.conf
    lineNum=$(grep -n "$varName" "$HOME/.config/theme-manager/theme-applier.conf" | cut -d ':' -f 1)
    sed -i "${lineNum}"',$d' "$HOME/.config/theme-manager/theme-applier.conf"
    echo "$newLine" >> "$HOME/.config/theme-manager/theme-applier.conf"
    lineNum=$((lineNum+1))
    tail -n "+$lineNum" "/tmp/theme-manager.conf" >> "$HOME/.config/theme-manager/theme-applier.conf"
}

# check if usage has to be printed
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printUsage
    exit 0
fi; if [ "$1" = "-s" ] || [ "$1" = "--set" ]; then
    editApplierConfig "$2" "$3"
    exit 0
fi; if [ "$1" = "-a" ] || [ "$1" = "--appy" ]; then
    tmp="$2"
    while [ -n "$tmp" ]; do
        rest="${tmp#?}"         # All but the first character of the string
        first="${tmp%"$rest"}"  # Remove $rest, and you're left with the first character
        case "$first" in
            h) updateHyprland ;;
            p) updateHyprpaper ;;
            d) updateDunst ;;
            b) updateBashRC ;;
            k) updateKitty ;;
            q) updateQT ;;
            w) updateWaybar ;;
            *) echo Wrong format on option: "$first"; exit 2 ;;
        esac
        tmp="$rest"
    done
    exit 0
fi; if [ "$1" = "--auto-update" ]; then
    # Exits the program if in the configuration auto_update is not enabled.
    doAutoUpdate=$(grep -n "auto_update" "$HOME/.config/theme-manager/theme-applier.conf" | cut -d ':' -f 2 | cut -d "=" -f 2)
    if [ "$doAutoUpdate" != "1" ]; then
        exit 0
    fi
fi

# read which configs to edit from the config file
while IFS= read -r line; do
    case "$line" in
        "update_hyprland=1") updateHyprland ;;
        "update_hyprpaper=1") updateHyprpaper ;;
        "update_dunst=1") updateDunst ;;
        "update_waybar=1") updateWaybar ;;
        "update_bashrc=1") updateBashRC ;;
        "update_kitty=1") updateKitty ;;
        "update_qt=1") updateQT ;;
    esac
done < "$HOME/.config/theme-manager/theme-applier.conf"