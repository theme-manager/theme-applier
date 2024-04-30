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
                    *" #0"*) newLine="    foreground = \"#$color1Hex\" #0";;
                    *" #1"*) newLine="    foreground = \"#$color0Hex\" #1";;
                    *" #2"*) newLine="    foreground = \"#$color3Hex\" #2";;
                esac
                sed -i "s/$line/$newLine/g" /tmp/dunst.conf ;;
        esac
    done < "/tmp/dunst.conf"

    mv /tmp/dunst.conf "$dunstPath"
}

editBashRC() {
    num=1
    lower=""
    while IFS= read -r line; do
        case "$line" in
            "export $1"*)
                newLine=$(cat <<EOF 
export ${1}='\\${2}' 
EOF
        )
                echo "$num | $line | $newLine" > /tmp/newLine
                # Throwing the Error "sed: -e Ausdruck #1, Zeichen 80: Nicht beendeter »s«-Befehl"....why?
                # Ah. It throws it because of the backslash... but how to...not do that?
                sed -i "${num}"',$d' /tmp/bashrc_edited
                echo "$num | $line | $newLine" >> /tmp/bashrc_edited
                #sed -i "${num}i $newLine" /tmp/bashrc_edited
                #sed -i "s|'e|'\/e|g" /tmp/bashrc_edited
                # implement this stuff with awk
                #awk -i inplace 'NR==FNR{a[$0];next} !($0 in a)' /tmp/newLine /tmp/bashrc_edited
                tr \''e' \''\\e' < /tmp/bashrc_edited > /tmp/newLine
                lower=""
        esac
        lower="$lower\n$line"
        num=$((num+1))
    done < "/tmp/bashrc_original"
    echo "$lower" >> /tmp/bashrc_edited
}

updateBashRC() {
    echo updating the bashrc theme...
    cp "$bashrcPath" "/tmp/bashrc_original"
    cp "$bashrcPath" /tmp/bashrc_edited

    editBashRC "COLOR_USER" "${color4ShRgb}"
    editBashRC "COLOR_PATH" "${color3ShRgb}"
    editBashRC "COLOR_GIT" "${color2ShRgb}"

    #rm /tmp/bashrc_original
    #mv /tmp/bashrc_edited "$bashrcPath"
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
        "update_qt=1") printColors ;;
    esac
done < "$HOME/.config/theme-applier/theme-applier.conf"