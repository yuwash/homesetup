for panel in $(find "$HOME"/.config/xfce4/panel -name '*.desktop')
do grep -H "Exec=chromium-browser %U" "$panel" \
	&& cat /usr/share/applications/firefox.desktop <(echo 'X-XFCE-Source=file:///usr/share/applications/firefox.desktop') > "$panel" \
	&& break
done
xfconf-query -c keyboard-layout -p /Default/XkbOptions/Group -s 'grp:alt_shift_toggle'
xfconf-query -c keyboard-layout -p /Default/XkbModel -s 'chromebook_m'
xfconf-query -c keyboard-layout -p /Default/XkbLayout -s 'us,us'
xfconf-query -c keyboard-layout -p /Default/XkbVariant -s 'colemak,altgr-intl'
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s '/usr/share/xfce4/backdrops/galliumos-turbines.jpg'
xfconf-query -c xfce4-panel -p /plugins/plugin-9 --create -s 'xkb-plugin'
