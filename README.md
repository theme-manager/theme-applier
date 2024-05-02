# theme-applier
Applies the active theme in ```$HOME/.config/themes/active``` to config files  
wich do not depend on .css files.  
Which config files get edited is dependant on the configuration in ```$HOME/.config/theme-applier/theme-applier.conf```.

## Installation
The installation is easy. Just put the shell script in your ```$HOME/.config/theme-applier``` directory and create the config file in the same directory.

## Usage

    theme-applier.sh [OPTIONS]"

    Options:
      -h  --help                      Show this help message
          --auto-update               Flag for automatic execution of this script.
                                      It checks the auto_update variable in the config and updates if it is set to 1
      -s  --set   <name> <on/off>     Set the variable <name> to <on/off>
                                          <auto>:     Automatically apply the current theme on system startup
                                          <hypr>:     Determines if hypr has to be updated when theme is applied
                                          <dunst>:    Determines if dunst has to be updated when theme is applied
                                          <bash>:     Determines if bashrc has to be updated when theme is applied
                                          <qt>:       Determines if qt theme has to be updated when theme is applied

## Example config file

    # The configuration file for the theme-applier
    auto_update=0
    update_hyprland=0
    update_dunst=1
    update_bashrc=1
    update_qt=0