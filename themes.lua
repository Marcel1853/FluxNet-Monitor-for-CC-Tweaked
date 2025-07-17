local themes = {}

themes.default = {
    background = colors.black,
    text = colors.white,
    tab_bg = colors.gray,
    tab_text = colors.white,
    tab_active_bg = colors.lightGray,
    tab_active_text = colors.black,
    reset_bg = colors.red,
    reboot_bg = colors.orange,
    error = colors.red, -- NEU
}

themes.blue = {
    background = colors.blue,
    text = colors.white,
    tab_bg = colors.lightBlue,
    tab_text = colors.white,
    tab_active_bg = colors.white,
    tab_active_text = colors.blue,
    reset_bg = colors.orange,
    reboot_bg = colors.red,
    error = colors.red,
}

-- Weitere Themes hier einfügen

return themes
