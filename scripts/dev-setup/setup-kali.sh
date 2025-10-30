#!/usr/bin/env bash

set -euo pipefail

# Dev setup cho Kali Linux (Debian-based)
# Gần tương đương Ubuntu script, tinh chỉnh gói theo Kali

VERSION="1.0.0"

usage() {
	echo "Usage: $0 [options]"
	echo ""
	echo "Options:"
	echo "  --with-zsh           Cài đặt Zsh + Oh My Zsh"
	echo "  --with-node          Cài đặt NVM + Node LTS + pnpm"
	echo "  --with-docker-cli    Cài đặt Docker CLI"
	echo "  --no-upgrade         Bỏ qua apt upgrade"
	echo "  -y, --yes            Tự động yes tất cả lời nhắc"
	echo "  -h, --help           Hiển thị trợ giúp"
	echo "  -v, --version        Hiển thị phiên bản"
}

log() { echo "[setup-kali] $*"; }

is_wsl() {
	grep -qi "microsoft" /proc/version 2>/dev/null || grep -qi "wsl" /proc/sys/kernel/osrelease 2>/dev/null
}

APT_FLAGS=()
DO_UPGRADE=1
INSTALL_ZSH=0
INSTALL_NODE=0
INSTALL_DOCKER_CLI=0

while [[ ${1:-} ]]; do
	case "$1" in
		--with-zsh) INSTALL_ZSH=1 ;;
		--with-node) INSTALL_NODE=1 ;;
		--with-docker-cli) INSTALL_DOCKER_CLI=1 ;;
		--no-upgrade) DO_UPGRADE=0 ;;
		-y|--yes) APT_FLAGS+=("-y") ;;
		-h|--help) usage; exit 0 ;;
		-v|--version) echo "$VERSION"; exit 0 ;;
		*) echo "Unknown option: $1"; usage; exit 1 ;;
	esac
	shift
done

require_cmd() { command -v "$1" >/dev/null 2>&1; }

apt_update_once() {
	log "apt update..."
	sudo apt-get update -y
}

install_apt_packages() {
	local -a packages=(
		build-essential
		ca-certificates
		curl
		wget
		git
		gnupg
		software-properties-common
		zip
		unzip
		tmux
		jq
		vim
		nano
		bash-completion
		tree
		htop
		net-tools
		openssh-client
		ripgrep
		fd-find
		fzf
		bat
		python3
		python3-pip
		pipx
	)

	apt_update_once
	log "Cài đặt gói cơ bản qua apt..."
	sudo apt-get install ${APT_FLAGS[*]:-} "${packages[@]}"

	if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
		sudo update-alternatives --install /usr/bin/bat bat /usr/bin/batcat 10 || true
	fi
	if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
		sudo update-alternatives --install /usr/bin/fd fd /usr/bin/fdfind 10 || true
	fi

	if [[ "$DO_UPGRADE" -eq 1 ]]; then
		log "apt upgrade (có thể mất vài phút)..."
		sudo apt-get upgrade ${APT_FLAGS[*]:-} -y
	fi
}

install_zsh() {
	[[ "$INSTALL_ZSH" -eq 1 ]] || return
	if ! require_cmd zsh; then
		log "Cài đặt zsh..."
		sudo apt-get install ${APT_FLAGS[*]:-} -y zsh
	fi
	if [[ -z "${ZSH:-}" ]] && [[ ! -d "$HOME/.oh-my-zsh" ]]; then
		log "Cài đặt Oh My Zsh..."
		export RUNZSH=no
		CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
	fi
	if [[ "$(basename \"$SHELL\")" != "zsh" ]]; then
		if is_wsl; then
			log "WSL phát hiện: bỏ qua chsh; bạn có thể tự đổi bằng: chsh -s $(command -v zsh)"
		else
			sudo chsh -s "$(command -v zsh)" "$USER" || true
		fi
	fi
}

install_nvm_node() {
	[[ "$INSTALL_NODE" -eq 1 ]] || return
	if [[ ! -d "$HOME/.nvm" ]]; then
		log "Cài đặt NVM..."
		curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
	fi
	# shellcheck disable=SC1091
	if [[ -s "$HOME/.nvm/nvm.sh" ]]; then . "$HOME/.nvm/nvm.sh"; fi
	if command -v nvm >/dev/null 2>&1; then
		log "Cài đặt Node LTS..."
		nvm install --lts
		nvm use --lts
		nvm alias default 'lts/*'
		log "Bật corepack và cài pnpm..."
		if command -v corepack >/dev/null 2>&1; then
			corepack enable || true
			corepack prepare yarn@stable --activate || true
		fi
		npm install -g pnpm@latest
	else
		log "Mở terminal mới để nvm khả dụng, sau đó chạy lại --with-node."
	fi
}

install_docker_cli() {
	[[ "$INSTALL_DOCKER_CLI" -eq 1 ]] || return
	log "Cài đặt Docker CLI..."
	apt_update_once
	sudo apt-get install ${APT_FLAGS[*]:-} -y docker.io docker-buildx-plugin docker-compose-plugin || true
	if getent group docker >/dev/null 2>&1; then
		sudo usermod -aG docker "$USER" || true
		log "Đã thêm user vào group docker (cần đăng nhập lại)."
	fi
}

configure_git_basics() {
	log "Cấu hình git cơ bản..."
	git config --global init.defaultBranch main || true
	git config --global pull.rebase false || true
	git config --global core.autocrlf false || true
}

ensure_pipx_path() { command -v pipx >/dev/null 2>&1 && pipx ensurepath || true; }

main() {
	log "Bắt đầu setup Kali v$VERSION"
	if ! require_cmd sudo; then log "Cần sudo"; exit 1; fi
	install_apt_packages
	install_zsh
	install_nvm_node
	install_docker_cli
	configure_git_basics
	ensure_pipx_path
	log "Hoàn tất. Mở terminal mới để nạp PATH."
}

main "$@"


