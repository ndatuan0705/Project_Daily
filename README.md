# Chuyên đề Linux — Project Daily

Bài thực hành theo tuần của môn Chuyên đề Linux. Mỗi thư mục con là một chủ đề
độc lập, có README và script chạy riêng.

## Danh sách chủ đề

| Thư mục | Chủ đề | Công cụ |
|---|---|---|
| [ChuDe_Tuan13](ChuDe_Tuan13) | Lab 6 — Thiết kế bộ điều khiển giao tiếp UART bằng Verilog | Icarus Verilog, GTKWave |

## Tải về và chạy trên Linux Mint

Chạy nguyên khối này sau mỗi lần boot (USB không có persistence thì mất hết
phần mềm đã cài, nên phải làm lại):

```bash
sudo apt update
sudo apt install -y git iverilog gtkwave make

git clone https://github.com/<tai-khoan>/<ten-repo>.git
cd <ten-repo>

chmod +x setup.sh ChuDe_Tuan13/sim/run_sim.sh
cd ChuDe_Tuan13
./sim/run_sim.sh
```

Lần sau chỉ cần `git clone` rồi `./setup.sh` ở gốc repo — script sẽ cài công cụ
và cấp quyền chạy cho mọi `run_sim.sh` trong repo.

Nên clone vào thư mục `~` (RAM / ổ cứng) thay vì vào USB, chạy nhanh hơn nhiều.
Nhớ `git push` trước khi tắt máy, nếu không mọi thay đổi sẽ mất.

## Ghi chú

- Kết quả mô phỏng (`sim/out/`, `.vcd`, `.vvp`, `.log`) không được commit — chạy
  script là sinh lại.
- File nguồn `.drawio` cũng không commit; sơ đồ đã export sẵn thành `.png` trong
  `docs/` của từng chủ đề.
- `.gitattributes` ở gốc repo chuẩn hoá ký tự xuống dòng, nên script `.sh` clone
  về Linux chạy được ngay mà không dính lỗi `bad interpreter`.
