#!/bin/sh

# -----------------------------------------------------------------------------
# Dissociate ROX 'SendTo/OpenWith' and/or Thunar with i
# -----------------------------------------------------------------------------

I_NAME="i[nfo]"
USER_HOME="$(eval echo ~${SUDO_USER})"	# XBPS

# Escape '[' and ']' in I_NAME for sed and find, using sed
I_NAME="$(echo "$I_NAME" | sed 's/\[/\\[/;s/\]/\\]/')"

# ROX

for i in "/etc/xdg/rox.sourceforge.net/SendTo" \
		"$USER_HOME/.config/rox.sourceforge.net/SendTo" \
		"$USER_HOME/.config/rox.sourceforge.net/OpenWith" \
		"/root/.config/rox.sourceforge.net/OpenWith"
do
	if [ -d "${i}" ]; then
		find "$(readlink -f "$i")" -type l -name "$I_NAME" -delete
	fi
done

# -----------------------------------------------------------------------------

# Thunar

CONFIG="$USER_HOME/.config/Thunar/uca.xml"
CONFIG_BAK="${CONFIG}.bak"

if [ -f "$CONFIG" ]; then
	cp -af "$CONFIG" "$CONFIG_BAK"
	
	sed -e "/<action>/i\ " -e "/<\/action>/a\ " -e "/<\/actions>/a\ " "$CONFIG_BAK" | \
		sed "/<action>/,/<\/action>/{H;d;};x;/<name>${I_NAME}<\/name>/d" | \
		sed "/^ *$/d" > "$CONFIG"
fi

# =============================================================================
