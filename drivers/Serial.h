
#include "xil_io.h"
#include <stdbool.h>
#include <vector>

#define BASE_ADRESS 0x00
#define CONTROL_REG BASE_ADRESS + 0x00
#define TX_REG BASE_ADRESS + 0x04
#define RX_REG BASE_ADRESS + 0x08

#define DUAL_STOP_POS 1
#define PARITY_POS 2
#define SIZE_POS 4
#define BAUDS_POS 6

#define READY_BIT_POS 9

typedef enum
{
    BITS5 = 0x3,
    BITS6 = 0x2,
    BITS7 = 0x1,
    BITS8 = 0x0
} BitsUART;

typedef enum
{
    BIT_STOP = 0,
    BIT_STOP_2 = 1
} BitSTOP;

typedef enum
{
    BIT_PAR,
    BIT_IMPAR,
    BIT_N
} BitParidad;

typedef enum
{
    SKIP_ALL,
    SKIP_NONE,
    SKIP_WHITESPACE
} LookaheadMode;

typedef enum
{
    SERIAL_5N1,
    SERIAL_6N1,
    SERIAL_7N1,
    SERIAL_8N1,
    SERIAL_5N2,
    SERIAL_6N2,
    SERIAL_7N2,
    SERIAL_8N2,
    SERIAL_5E1,
    SERIAL_6E1,
    SERIAL_7E1,
    SERIAL_8E1,
    SERIAL_5E2,
    SERIAL_6E2,
    SERIAL_7E2,
    SERIAL_8E2,
    SERIAL_5O1,
    SERIAL_6O1,
    SERIAL_7O1,
    SERIAL_8O1,
    SERIAL_5O2,
    SERIAL_6O2,
    SERIAL_7O2,
    SERIAL_8O2
} SerialConfig;

class Serial
{
private:
    // Dirección del bloque IP.
    uint32_t _address;
    // Frecuencia del AXI del bloque IP.
    uint32_t _frequency;
    /**
     * @brief Método para leer el valor del registro.
     *
     * @param reg Dirección a leer.
     * @return uint32_t Valor leído.
     */
    uint32_t readReg(int reg);

public:
    /**
     * @brief Constructor de la clase Serial.
     *
     * @param address Dirección del bloque IP.
     */
    Serial(uint32_t address);
    /**
     * @brief Destructor de la clase.
     *
     */
    ~Serial();

    /**
     * @brief Disponibilidad de la UART.
     *
     * @return int Datos disponibles de la UART.
     */
    int available();
    int availableForWrite();
    /**
     * @brief Comenzar el funcionamiento de la UART.
     *
     * @param baud Baudios de la UART.
     */
    void begin(long baud);
    void begin(long baud, SerialConfig config);
    void end();
    bool find(char target);
    bool find(char target, size_t length);
    bool findUntil(char target, char terminal);
    void flush();
    float parseFloat();
    float parseFloat(LookaheadMode lookahead);
    float parseFloat(LookaheadMode lookahead, char ignore);
    float parseInt();
    float parseInt(LookaheadMode lookahead);
    float parseInt(LookaheadMode lookahead, char ignore);
    int peek();
    /**
     * @brief Método para transmitir datos de la UART.
     *
     * @param val Cadena de transmisión.
     * @return size_t Tamaño transmitido.
     */
    size_t print(char *val);
    /**
     * @brief Método para transmitir datos de la UART.
     *
     * @param val Cadena de transmisión.
     * @param format Formateo de datos.
     * @return size_t Tamaño transmitido.
     */
    size_t print(char *val, UARTFormat format);
    /**
     * @brief Método para transmitir datos de la UART.
     *
     * @param val Cadena de transmisión.
     * @return size_t Tamaño transmitido.
     */
    size_t println(char *val);
    /**
     * @brief Método para transmitir datos de la UART.
     *
     * @param val Cadena de transmisión.
     * @param format Formateo de datos.
     * @return size_t Tamaño transmitido.
     */
    size_t println(char *val, UARTFormat format);
    /**
     * @brief Método para leer por la UART.
     *
     * @return int Byte leído por la UART.
     */
    int read();
    /**
     * @brief Método para leer bytes por la UART.
     *
     * @param buffer Buffer con los datos leídos.
     * @param length Tamaño de los datos del buffer.
     * @return int Tamaño de los datos del buffer.
     */
    int readBytes(char buffer, int length);
    /**
     * @brief Método para leer bytes por la UART.
     *
     * @param buffer Buffer de bytes con los datos leídos.
     * @param length Tamaño de los datos del buffer.
     * @return int Tamaño de los datos del buffer.
     */
    int readBytes(byte buffer, int length);
    size_t readBytesUntil(char character, char buffer, int length);
    size_t readBytesUntil(char character, byte buffer, int length);

    String readString();
    String readStringUntil(char terminator);
    void setTimeout(long time);
    /**
     * @brief Método para escribir por la UART.
     *
     * @param val Dato a transmitir.
     * @return size_t Tamaño de datos a transmitir.
     */
    size_t write(uint8_t val);
    /**
     * @brief Método para escribir por la UART.
     *
     * @param str Cadena a transmitir.
     * @return size_t Tamaño de datos a transmitir.
     */
    size_t write(uint8_t str);
    /**
     * @brief Método para escribir por la UART.
     *
     * @param buf Buffer de datos de envío.
     * @param len Tamaño a transmitir.
     * @return size_t Tamaño de datos a transmitir.
     */
    size_t write(uint8_t *buf, size_t len);
};
