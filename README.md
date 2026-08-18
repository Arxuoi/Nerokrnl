# MOTO ENGINE LAB
Simulator mesin motor 2D berbasis Godot 4. Workshop mengubah geometri dan sistem yang saling berinteraksi; Dyno menjalankan sweep deterministik; Track memakai output torsi build yang sama.

## Main cepat
Jalankan `MotoEngineLab.exe`. Pilih **NEW BUILD**, atur build di **ENGINE LAB**, tekan **START ENGINE**, lalu buka **DYNO**. Pada Track: `W` throttle, `E/Q` pindah gigi, `C` clutch. Build disimpan sebagai JSON `.melbuild`; CSV dyno ada di folder user Godot.

## Build dari source
Buka dengan Godot 4.3+ dan jalankan project. Ekspor preset `Windows Desktop`, atau `godot --headless --export-release "Windows Desktop" build/MotoEngineLab.exe` setelah export template terpasang.

## Paket release Windows
Paket siap main tersedia di `build/MOTO_ENGINE_LAB_Windows_x64.rar`. Ekstrak seluruh folder, lalu jalankan `MotoEngineLab.exe`; file `.pck` harus tetap berada di folder yang sama. Integritas arsip dapat diperiksa memakai file `.rar.sha256` yang disertakan.
