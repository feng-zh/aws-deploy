#!/usr/bin/env bash
# Refer to https://gist.github.com/garnelediekatze/5801fb5716fa8b3c512a10e99086079a

version_ge(){
	test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"
}

check_kernel_version() {
	local kernel_version=$(uname -r | cut -d- -f1)
	if version_ge ${kernel_version} 4.9; then
		return 0
	else
		return 1
	fi
}

sysctl_config() {
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
	cat <<-EOF > /etc/sysctl.d/10-bbr.conf
	net.core.default_qdisc=fq
	net.ipv4.tcp_congestion_control=bbr
	EOF
	sysctl -p /etc/sysctl.d/10-bbr.conf >/dev/null 2>&1
}

check_kernel_version
if [ $? -eq 0 ]; then
	sysctl_config
fi
