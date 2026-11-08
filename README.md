# Chuyên đề Linux — Project Daily

Bài thực hành theo tuần. Mỗi thư mục con là một chủ đề độc lập, có README riêng
hướng dẫn cài đặt và chạy.

| Thư mục | Chủ đề | Công cụ |
|---|---|---|
| [ChuDe_Tuan13](ChuDe_Tuan13) | Lab 6 — Thiết kế bộ điều khiển giao tiếp UART bằng Verilog | Icarus Verilog, GTKWave |

## Tải về và chạy trên Linux Mint

Chạy khối này sau mỗi lần boot lại từ USB:

```bash
sudo apt update
sudo apt install -y git iverilog gtkwave make

git clone https://github.com/ndatuan0705/Project_Daily.git
cd Project_Daily/ChuDe_Tuan13

chmod +x sim/run_sim.sh
./sim/run_sim.sh
```

Repo không commit kết quả do công cụ sinh ra (`sim/out/`, `.vcd`, `.vvp`,
`.log`), file nguồn `.drawio` và file báo cáo `.docx`. Sơ đồ đã export sẵn
thành `.png` trong `docs/` của từng chủ đề nên README hiển thị được ngay trên
GitHub.

File `.gitattributes` chuẩn hoá ký tự xuống dòng về LF cho `.v`, `.sh`, `.mk`,
`.md`. Nếu thiếu, script `.sh` commit từ Windows sẽ mang ký tự CR và Linux báo
`bad interpreter`.
