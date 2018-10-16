#include <array>
#include <cstdint>
#include <functional>
#include <iostream>
#include <type_traits>
#include <unordered_map>

namespace bits {
// can be used for 4 or 12 bit integers
template <typename T> class machine_int {
  static_assert(std::is_same_v<T, uint8_t> || std::is_same_v<T, int8_t> ||
                std::is_same_v<T, uint16_t>);

public:
  static constexpr auto bit_mask = std::make_unsigned_t<T>(-1) << 4;

  machine_int() : value(0){};
  inline machine_int(const T val) : value(val << 4) { /* TODO check valid val */
  }
  inline machine_int<T> &operator=(const T val) { /*TODO check valid val */
    value = val << 4;
  }

  inline machine_int(const machine_int<T> &val) : value(val.value) {}
  inline machine_int<T> &operator=(const machine_int<T> val) {
    value = val.value;
    return *this;
  }

  // operators:
  template <typename U>
  inline machine_int<T> operator+(const machine_int<U> rhs) {
    return ((value + rhs.value) & bit_mask) >> 4;
  }
  inline machine_int<T> operator+(const T rhs) {
    return *this + machine_int<T>{rhs};
  }

  template <typename U>
  inline machine_int<T> &operator+=(const machine_int<U> rhs) {
    value = (*this + rhs).value;
    return *this;
  }
  inline machine_int<T> &operator+=(const T rhs) {
    return *this += machine_int<T>{rhs};
  }

  template <typename U>
  inline machine_int<T> operator-(const machine_int<U> rhs) {
    return ((value - rhs.value) & bit_mask) >> 4;
  }
  inline machine_int<T> operator-(const T rhs) {
    return *this - machine_int<T>{rhs};
  }

  template <typename U>
  inline machine_int<T> &operator-=(const machine_int<U> rhs) {
    value = (*this - rhs).value;
    return *this;
  }
  inline machine_int<T> &operator-=(const T rhs) {
    return *this -= machine_int<T>{rhs};
  }

  inline machine_int<T> &operator++() {
    *this += 1;
    return *this;
  }
  inline machine_int<T> operator++(int) {
    const auto ret = *this;
    *this += 1;
    return ret;
  }

  inline machine_int<T> &operator--() {
    *this -= 1;
    return *this;
  }
  inline machine_int<T> operator--(int) {
    const auto ret = *this;
    *this -= 1;
    return ret;
  }

  // access value
  inline T get_value() const { return value >> 4; }

private:
  T value; // we use the TOP 4 bits of value, and then mask off the bottom 4
};
} // namespace bits

using uint4_t = bits::machine_int<uint8_t>;
using int4_t = bits::machine_int<int8_t>;
using uint12_t = bits::machine_int<uint16_t>;

std::ostream &operator<<(std::ostream &os, uint4_t val) {
  return os << (unsigned int)val.get_value();
}
std::ostream &operator<<(std::ostream &os, int4_t val) {
  return os << (int)val.get_value();
}
std::ostream &operator<<(std::ostream &os, uint12_t val) {
  return os << (unsigned int)val.get_value();
}

struct Machine_State {
  uint12_t pc{0};
  std::array<uint12_t, 3> callstack{0, 0, 0};
  size_t curr_callstack_offset{0};
  std::array<uint4_t, 16> gprs{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

  std::array<uint8_t, 4096> rom{};
  std::array<std::array<uint4_t, 256>, 8> ram_banks{};
  size_t selected_ram_bank{0};
};

enum class Opcode {
  NOP,
  JCN,
  FIM,
  SRC,
  FIN,
  JIN,
  JUN,
  JMS,
  INC,
  ISZ,
  ADD,
  SUB,
  LD,
  XCH,
  BBL,
  LDM,
  WRM,
  WMP,
  WRR,
  WPM,
  WR0,
  WR1,
  WR2,
  WR3,
  SBM,
  RDM,
  RDR,
  ADM,
  RD0,
  RD1,
  RD2,
  RD3,
  CLB,
  CLC,
  IAC,
  CMC,
  CMA,
  RAL,
  RAR,
  TCC,
  DAC,
  TCS,
  STC,
  DAA,
  KBP,
  DCL,
};

Opcode get_current_opcode(Machine_State &state) {
  auto opbyte1 = state.rom.at(state.pc.get_value());
  switch (opbyte1 >> 4) {
  case 0b0000:
    return Opcode::NOP;
  case 0b0001:
    return Opcode::JCN;
  case 0b0010:
    switch (opbyte1 & 1) {
    case 0b0:
      return Opcode::FIM;
    case 0b1:
      return Opcode::SRC;
    }
  case 0b0011:
    switch (opbyte1 & 1) {
    case 0b0:
      return Opcode::FIN;
    case 0b1:
      return Opcode::JIN;
    }
  case 0b0100:
    return Opcode::JUN;
  case 0b0101:
    return Opcode::JMS;
  case 0b0110:
    return Opcode::INC;
  case 0b0111:
    return Opcode::ISZ;
  case 0b1000:
    return Opcode::ADD;
  case 0b1001:
    return Opcode::SUB;
  case 0b1010:
    return Opcode::LD;
  case 0b1011:
    return Opcode::XCH;
  case 0b1100:
    return Opcode::BBL;
  case 0b1101:
    return Opcode::LDM;
  case 0b1110:
    switch (opbyte1 & 0xf) {
    case 0b0000:
      return Opcode::WRM;
    case 0b0001:
      return Opcode::WMP;
    case 0b0010:
      return Opcode::WRR;
    case 0b0011:
      return Opcode::WR0;
    case 0b0100:
      return Opcode::WR1;
    case 0b0101:
      return Opcode::WR2;
    case 0b0110:
      return Opcode::WR3;
    case 0b0111:
      return Opcode::SBM;
    case 0b1000:
      return Opcode::RDM;
    case 0b1001:
      return Opcode::RDR;
    case 0b1010:
      return Opcode::ADM;
    case 0b1011:
      return Opcode::RD0;
    case 0b1100:
      return Opcode::RD1;
    case 0b1101:
      return Opcode::RD2;
    case 0b1110:
      return Opcode::RD3;
    }
  case 0b1111:
    switch (opbyte1 & 0xf) {
    case 0b0000:
      return Opcode::CLB;
    case 0b0001:
      return Opcode::CLC;
    case 0b0010:
      return Opcode::IAC;
    case 0b0011:
      return Opcode::CMC;
    case 0b0100:
      return Opcode::CMA;
    case 0b0101:
      return Opcode::RAL;
    case 0b0110:
      return Opcode::RAR;
    case 0b0111:
      return Opcode::TCC;
    case 0b1000:
      return Opcode::DAC;
    case 0b1001:
      return Opcode::TCS;
    case 0b1010:
      return Opcode::STC;
    case 0b1011:
      return Opcode::DAA;
    case 0b1100:
      return Opcode::KBP;
    case 0b1101:
      return Opcode::DCL;
    }
  }

  std::cerr << "Failed to decode opcode!!" << std::endl;
  abort();
}

void tick(Machine_State &state) {
  const std::unordered_map<Opcode, std::function<void(Machine_State &)>>
      opcode_handlers{
          {Opcode::NOP, [](Machine_State &state) {}},
          {Opcode::JCN, [](Machine_State &state) {}},
          {Opcode::FIM, [](Machine_State &state) {}},
          {Opcode::SRC, [](Machine_State &state) {}},
          {Opcode::FIN, [](Machine_State &state) {}},
          {Opcode::JIN, [](Machine_State &state) {}},
          {Opcode::JUN, [](Machine_State &state) {}},
          {Opcode::JMS, [](Machine_State &state) {}},
          {Opcode::INC, [](Machine_State &state) {}},
          {Opcode::ISZ, [](Machine_State &state) {}},
          {Opcode::ADD, [](Machine_State &state) {}},
          {Opcode::SUB, [](Machine_State &state) {}},
          {Opcode::LD, [](Machine_State &state) {}},
          {Opcode::XCH, [](Machine_State &state) {}},
          {Opcode::BBL, [](Machine_State &state) {}},
          {Opcode::LDM, [](Machine_State &state) {}},
          {Opcode::WRM, [](Machine_State &state) {}},
          {Opcode::WMP, [](Machine_State &state) {}},
          {Opcode::WRR, [](Machine_State &state) {}},
          {Opcode::WPM, [](Machine_State &state) {}},
          {Opcode::WR0, [](Machine_State &state) {}},
          {Opcode::WR1, [](Machine_State &state) {}},
          {Opcode::WR2, [](Machine_State &state) {}},
          {Opcode::WR3, [](Machine_State &state) {}},
          {Opcode::SBM, [](Machine_State &state) {}},
          {Opcode::RDM, [](Machine_State &state) {}},
          {Opcode::RDR, [](Machine_State &state) {}},
          {Opcode::ADM, [](Machine_State &state) {}},
          {Opcode::RD0, [](Machine_State &state) {}},
          {Opcode::RD1, [](Machine_State &state) {}},
          {Opcode::RD2, [](Machine_State &state) {}},
          {Opcode::RD3, [](Machine_State &state) {}},
          {Opcode::CLB, [](Machine_State &state) {}},
          {Opcode::CLC, [](Machine_State &state) {}},
          {Opcode::IAC, [](Machine_State &state) {}},
          {Opcode::CMC, [](Machine_State &state) {}},
          {Opcode::CMA, [](Machine_State &state) {}},
          {Opcode::RAL, [](Machine_State &state) {}},
          {Opcode::RAR, [](Machine_State &state) {}},
          {Opcode::TCC, [](Machine_State &state) {}},
          {Opcode::DAC, [](Machine_State &state) {}},
          {Opcode::TCS, [](Machine_State &state) {}},
          {Opcode::STC, [](Machine_State &state) {}},
          {Opcode::DAA, [](Machine_State &state) {}},
          {Opcode::KBP, [](Machine_State &state) {}},
          {Opcode::DCL, [](Machine_State &state) {}},
      };
}

int main(int argc, char **argv) {
  // unbuffer
  setbuf(stdin, NULL);
  setbuf(stdout, NULL);

  if (argc < 2) {
    std::cout << "Usage: " << argv[0] << " <rom file>" << std::endl;
    return 1;
  }

  Machine_State state;
  // load rom:
  FILE *fd = fopen(argv[1], "r");
  if (!fd) {
    perror("Open:");
    return 1;
  }
  if (fread(state.rom.data(), 1, state.rom.size(), fd) != state.rom.size()) {
    perror("Read:");
    return 1;
  }

  // emulate
  while (true) {
    tick(state);
  }
}
