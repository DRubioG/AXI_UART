#include "Serial.h"

uint32_t Serial::readReg(int reg)
{
    return Xil_In32(_address + reg);
}

Serial::Serial(uint32_t address, uint32_t frequency)
{
    _address = address;
    _frequency = frequency;
    Xil_Out32(_address + CONTROL_REG, reg_blank | baud);
}

Serial::~Serial()
{
}

int Serial::available()
{
    uint32_t reg = readReg(REG1);

    if ((reg >> 4) & 0x01)
    {
        uint32_t read_bytes = readReg(REG2);
        return read_bytes
    }
    return 0;
}

int Serial::availableForWrite()
{
    uint32_t reg = readReg(REG1);

    if ((reg >> 4) & 0x01)
    {
        uint32_t read_bytes = readReg(REG2);
        return read_bytes
    }
    return 0;
}

void begin(long baud)
{
    uint32_t reg = readReg(CONF);

    uint32_t reg_blank = reg & 0x3F;

    uint32_t baud_counts = _frequency / baud;

    BitsUART data;
    BitSTOP bit_stop;
    BitParidad bit_par;

    data = BITS8;
    bit_stop = BIT_STOP;
    bit_par = BIT_N;

    Xil_Out32(_address + CONTROL_REG, reg_blank | (baud << BAUDS_POS));
}

void begin(long baud, SerialConfig config)
{
    begin(baud);

    uint32_t reg = readReg(CONF);
    uint32_t reg_blank = reg & ~0x3D;

    BitsUART data;
    BitSTOP bit_stop;
    BitParidad bit_par;

    uint8_t type_serial = 0;

    switch (config)
    {
    case SERIAL_5N1:
        data = BITS5;
        bit_stop = BIT_STOP;
        bit_par = BIT_N;
        break;
    case SERIAL_6N1:
        data = BITS6;
        bit_stop = BIT_STOP;
        bit_par = BIT_N;
        break;
    case SERIAL_7N1:
        data = BITS7;
        bit_stop = BIT_STOP;
        bit_par = BIT_N;
        break;
    case SERIAL_8N1:
        data = BITS8;
        bit_stop = BIT_STOP;
        bit_par = BIT_N;
        break;
    case SERIAL_5N2:
        data = BITS5;
        bit_stop = BIT_STOP_2;
        bit_par = BIT_N;
        break;
    case SERIAL_6N2:
        data = BITS6;
        bit_stop = BIT_STOP_2;
        bit_par = BIT_N;
        break;
    case SERIAL_7N2:
        data = BITS7;
        bit_stop = BIT_STOP_2;
        bit_par = BIT_N;
        break;
    case SERIAL_8N2:
        data = BITS8;
        bit_stop = BIT_STOP_2;
        bit_par = BIT_N;
        break;
    case SERIAL_5E1:
        data = BITS5;
        bit_stop = BIT_STOP;
        bit_par = BIT_IMPAR;
        break;
    case SERIAL_6E1:
        data = BITS6;
        bit_stop = BIT_STOP;
        bit_par = BIT_IMPAR;
        break;
    case SERIAL_7E1:
        data = BITS7;
        bit_stop = BIT_STOP;
        bit_par = BIT_IMPAR;
        break;
    case SERIAL_8E1:
        data = BITS8;
        bit_stop = BIT_STOP;
        bit_par = BIT_IMPAR;
        break;
    case SERIAL_5E2:
        data = BITS5;
        bit_stop = BIT_STOP_2;
        bit_par = BIT_IMPAR;
        break;
    case SERIAL_6E2:
        data = BITS6;
        bit_stop = BIT_STOP_2;
        bit_par = BIT_IMPAR;
        break;
    case SERIAL_7E2:
        data = BITS7;
        bit_stop = BIT_STOP_2;
        bit_par = BIT_IMPAR;
        break;
    case SERIAL_8E2:
        data = BITS8;
        bit_stop = BIT_STOP_2;
        bit_par = BIT_IMPAR;
        break;
    case SERIAL_5O1:
        data = BITS5;
        bit_stop = BIT_STOP;
        bit_par = BIT_PAR;
        break;
    case SERIAL_6O1:
        data = BITS6;
        bit_stop = BIT_STOP;
        bit_par = BIT_PAR;
        break;
    case SERIAL_7O1:
        data = BITS7;
        bit_stop = BIT_STOP;
        bit_par = BIT_PAR;
        break;
    case SERIAL_8O1:
        data = BITS8;
        bit_stop = BIT_STOP;
        bit_par = BIT_PAR;
        break;
    case SERIAL_5O2:
        data = BITS5;
        bit_stop = BIT_STOP_2;
        bit_par = BIT_PAR;
        break;
    case SERIAL_6O2:
        data = BITS6;
        bit_stop = BIT_STOP_2;
        bit_par = BIT_PAR;
        break;
    case SERIAL_7O2:
        data = BITS7;
        bit_stop = BIT_STOP_2;
        bit_par = BIT_PAR;
        break;
    case SERIAL_8O2:
        data = BITS8;
        bit_stop = BIT_STOP_2;
        bit_par = BIT_PAR;
        break;

    default:
        break;
    }

    type_serial = (bit_stop << DUAL_STOP_POS) | (bit_par << PARITY_POS) | (data << SIZE_POS);

    Xil_Out32(_address + CONTROL_REG, reg_blank | (type_serial << DUAL_STOP_POS));
}

void Serial::end()
{
    uint32_t reg = Xil_In32(_address + CONTROL_REG);
    Xil_Out32(reg & ~0x1)
}

size_t Serial::print(char *val)
{
    size_t size = sizeof(val);

    for (size_t i = 0; i < size; i++)
    {
        Xil_Out32(_address + TX_REG, val[i]);
        while (~((Xil_In32(_address) >> READY_BIT_POS) & 0x1));
    }

    return size;
}

size_t Serial::println(char *val)
{
    size_t size = sizeof(val);

    for (size_t i = 0; i < size; i++)
    {
    }

    Xil_Out32(_address + TX_REG);

    return size;
}

int Serial::read()
{
    uint32_t read = Xil_Int32(_address + RX_REG);

    int data = read & 0xFF;

    return data;
}

size_t Serial::write(int val)
{
    print(val);
}