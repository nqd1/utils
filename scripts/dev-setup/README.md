Dev Setup cho Ubuntu, Arch, Kali (và WSL)

- Cài đặt gói CLI cơ bản: build-essential, git, curl, ripgrep, fzf, fd, bat, tmux, jq, v.v.
- Tuỳ chọn cài: Zsh + Oh My Zsh
- Tuỳ chọn cài: NVM + Node LTS + pnpm (và enable corepack/yarn)
- Tuỳ chọn cài: Docker CLI (không cấu hình daemon trên WSL)
- Cấu hình git mặc định phù hợp Linux/WSL

```bash
chmod +x scripts/dev-setup/setup-ubuntu.sh
# chmod +x scripts/dev-setup/setup-arch.sh
# chmod +x scripts/dev-setup/setup-kali.sh

# Cơ bản (gói CLI + cấu hình git)
scripts/dev-setup/setup-ubuntu.sh -y
#scripts/dev-setup/setup-arch.sh -y
# scripts/dev-setup/setup-kali.sh -y

# Thêm Zsh + Node LTS + Docker CLI
# scripts/dev-setup/setup-ubuntu.sh -y --with-zsh --with-node --with-docker-cli
# scripts/dev-setup/setup-arch.sh -y --with-zsh --with-node --with-docker-cli
# scripts/dev-setup/setup-kali.sh -y --with-zsh --with-node --with-docker-cli

# Bỏ qua apt upgrade (nhanh hơn, ít can thiệp)
scripts/dev-setup/setup-ubuntu.sh -y --no-upgrade
# scripts/dev-setup/setup-arch.sh -y --no-upgrade
# scripts/dev-setup/setup-kali.sh -y --no-upgrade
```

Tuỳ chọn

- `--with-zsh`: Cài đặt Zsh và Oh My Zsh (không ép đổi shell trên WSL)
- `--with-node`: Cài đặt NVM + Node LTS + pnpm, bật corepack/yarn nếu khả dụng
- `--with-docker-cli`: Cài docker CLI, buildx, compose plugin (không cài daemon trên WSL)
- `--no-upgrade`: Bỏ qua `apt upgrade`
- `-y, --yes`: Tự động đồng ý mọi lời nhắc từ apt
- `-h, --help`: Trợ giúp
- `-v, --version`: Phiên bản script

Lưu ý WSL

- Script tự phát hiện WSL và tránh cấu hình không cần thiết (ví dụ chsh, docker daemon).
- Đề xuất dùng Docker Desktop với tích hợp WSL nếu cần daemon.
- Nếu cần systemd trong WSL, bật qua `wsl.conf` (Windows 11).

Ghi chú theo distro

- Ubuntu/Kali: lệnh `bat` là `batcat`, `fd` là `fdfind` (script đã map alias qua update-alternatives).
- Arch: dùng `pacman`, bật `--noconfirm` qua `-y` của script; có thể enable docker daemon qua `systemctl` nếu không chạy WSL.
