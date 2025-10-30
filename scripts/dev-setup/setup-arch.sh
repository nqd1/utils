#!/usr/bin/env bash

set -euo pipefail

# Dev setup cho Arch Linux (bao gồm Arch trên WSL)
# Tính năng tương tự setup-ubuntu.sh, dùng pacman

VERSION="1.0.0"

usage() {
	echo "Usage: $0 [options]"
	echo ""
	echo "Options:"
	echo "  --with-zsh           Cài đặt Zsh + Oh My Zsh"
	echo "  --with-node          Cài đặt NVM + Node LTS + pnpm"
	echo "  --with-docker-cli    Cài đặt Docker CLI (không cài daemon trên WSL)"
	echo "  --no-upgrade         Bỏ qua pacman -Syu"
	echo "  -y, --yes            Tự động yes tất cả lời nhắc"
	echo "  -h, --help           Hiển thị trợ giúp"
	echo "  -v, --version        Hiển thị phiên bản"
}

log() { echo "[setup-arch] $*"; }

is_wsl() {
	grep -qi "microsoft" /proc/version 2>/dev/null || grep -qi "wsl" /proc/sys/kernel/osrelease 2>/dev/null
}

PACMAN_FLAGS=(--needed)
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
		-y|--yes) PACMAN_FLAGS+=(--noconfirm) ;;
		-h|--help) usage; exit 0 ;;
		-v|--version) echo "$VERSION"; exit 0 ;;
		*) echo "Unknown option: $1"; usage; exit 1 ;;
	esac
	shift
done

require_cmd() { command -v "$1" >/dev/null 2>&1; }

pacman_sync() {
	log "pacman -Sy..."
	sudo pacman -Sy --noconfirm
}

install_pacman_packages() {
	local -a packages=(
		base-devel
		ca-certificates
		curl
		wget
		git
		gnupg
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
		openssh
		ripgrep
		fd
		fzf
		bat
		python
		python-pip
		python-pipx
	)

	pacman_sync
	if [[ "$DO_UPGRADE" -eq 1 ]]; then
		log "pacman -Syu..."
		sudo pacman -Syu --noconfirm || true
	fi

	log "Cài đặt gói cơ bản..."
	sudo pacman -S ${PACMAN_FLAGS[*]:-} "${packages[@]}"
}

install_zsh() {
	[[ "$INSTALL_ZSH" -eq 1 ]] || return
	if ! require_cmd zsh; then
		log "Cài đặt zsh..."
		sudo pacman -S ${PACMAN_FLAGS[*]:-} zsh
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
	log "Cài docker CLI/buildx/compose..."
	sudo pacman -S ${PACMAN_FLAGS[*]:-} docker docker-buildx docker-compose || true
	if is_wsl; then
		log "WSL phát hiện: không cấu hình daemon. Dùng Docker Desktop tích hợp WSL."
	else
		log "Nếu cần daemon đầy đủ, enable dịch vụ: sudo systemctl enable --now docker"
	fi
	if getent group docker >/dev/null 2>&1; then
		sudo usermod -aG docker "$USER" || true
		log "Đã thêm user vào group docker (cần đăng nhập lại)."
	fi
}

configure_git_basics() {
	log "Cấu hình git cơ bản..."
	git config --global init.defaultBranch main || true
	git config --global pull.rebase false || true
	if is_wsl; then git config --global core.autocrlf input || true; else git config --global core.autocrlf false || true; fi
}

ensure_pipx_path() { command -v pipx >/dev/null 2>&1 && pipx ensurepath || true; }

main() {
	log "Bắt đầu setup Arch v$VERSION"
	if ! require_cmd sudo; then log "Cần sudo"; exit 1; fi
	install_pacman_packages
	install_zsh
	install_nvm_node
	install_docker_cli
	configure_git_basics
	ensure_pipx_path
	log "Hoàn tất. Mở terminal mới để nạp PATH."
	if is_wsl; then log "WSL gợi ý: Bật systemd nếu cần dịch vụ nền (Windows 11)."; fi
}

main "$@"


