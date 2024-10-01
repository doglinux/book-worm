#!/bin/sh

# -----------------------------------------------------------------------------
# Associate ROX 'SendTo/OpenWith' and/or Thunar with i
# -----------------------------------------------------------------------------

[ "$(pwd)" = '/' ] && DOT='' || DOT='.'	# Woof/Fatdog build system
USER_HOME="$(eval echo ~${SUDO_USER})"	# XBPS

I_NAME="i[nfo]"
I_CMD="i"
I_PATH="/usr/share/applications/i.desktop"
I_ICON="i"	# was 'dialog-information'
# ^ icon created using vovchik's Pikona: http://oldforum.puppylinux.com/viewtopic.php?t=49129

# ROX

ROX_PATH=''
GLOBS="${DOT}/usr/share/mime/globs"
TYPES="${DOT}/usr/share/mime/types"

for i in "${DOT}/etc/xdg/rox.sourceforge.net/SendTo" \
		"${DOT}${USER_HOME}/.config/rox.sourceforge.net/SendTo" \
		"${DOT}${USER_HOME}/.config/rox.sourceforge.net/OpenWith" \
		"${DOR}/root/.config/rox.sourceforge.net/OpenWith"
do
	if [ -d "$i" ]; then
		grep -qi '^Void' /etc/issue 2>/dev/null && [ "$i" != "${i#${DOT}/etc}" ] && continue
		ROX_PATH="$(readlink -f "$i")"
		break
	fi
done

if [ -d "$ROX_PATH" ]; then
	grep -hv '^#' "${GLOBS}" "${TYPES}" | cut -f1 -d ':' | tr '/' '_' | sort -u| \
	while read -r i; do
		mkdir -p "${ROX_PATH}/.${i}"
		ln -sfT "${I_PATH}" "${ROX_PATH}/.${i}/${I_NAME}"
	done
	
	mkdir -p "${ROX_PATH}/.inode_unknown"
	ln -sfT "${I_PATH}" "${ROX_PATH}/.inode_unknown/${I_NAME}"
	ln -sfT "${I_PATH}" "${ROX_PATH}/${I_NAME}" 
fi

# -----------------------------------------------------------------------------

# Thunar

if [ "$(pwd)" = "/" ] && (type thunar >/dev/null 2>&1 || type Thunar >/dev/null 2>&1); then
	TEMPLATE="<action>
	<icon>i</icon>
	<name>${I_NAME}</name>
	<command>${I_CMD} %f</command>
	<description>Get a lot of info about a file.</description>
	<patterns>*</patterns>
	<directories/>
	<audio-files/>
	<image-files/>
	<other-files/>
	<text-files/>
	<video-files/>
</action>"
	
	CONFIG="$USER_HOME/.config/Thunar/uca.xml"
	CONFIG_BAK="${CONFIG}.bak"
	
	if [ -f "$CONFIG" ]; then
		cp -af "$CONFIG" "$CONFIG_BAK"
		
		grep -qF "<name>${I_NAME}</name>" "$CONFIG_BAK" || {
			echo "$(grep -v '</actions>' "$CONFIG_BAK")
${TEMPLATE}
</actions>" > "$CONFIG"
		}
	else
		mkdir -p "${CONFIG%/*}"
		echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<actions>
${TEMPLATE}
</actions>" > "$CONFIG"
	fi
fi

# =============================================================================
