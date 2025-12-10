#!/usr/bin/env bash
set -e

echo "=== APT update & ARM toolchain + OpenOCD install ==="
sudo apt update
sudo apt install -y \
  gcc-arm-none-eabi \
  binutils-arm-none-eabi \
  gdb-multiarch \
  openocd

echo
echo "=== Versions installed ==="
echo "arm-none-eabi-gcc:"
arm-none-eabi-gcc --version || echo "arm-none-eabi-gcc not found (install failed)."

echo
echo "openocd:"
openocd --version || echo "openocd not found (install failed)."

echo
echo "=== Notes ==="
echo "- Toolchain: arm-none-eabi-* (gcc, objdump, etc.)"
echo "- Debugger: gdb-multiarch (use with OpenOCD target remote localhost:3333)."
echo "- OpenOCD configs: /usr/share/openocd/scripts/"
echo
echo "Example OpenOCD:"
echo "  openocd -f interface/stlink.cfg -f target/stm32f1x.cfg"
echo
echo "Example GDB session:"
echo "  gdb-multiarch build/firmware.elf"
echo "    (gdb) target remote localhost:3333"

