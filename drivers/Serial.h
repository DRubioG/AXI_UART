
#include "xil_io.h"
#include <vector>

#define BASE_ADRESS 0x00


typedef enum
{
    SKIP_ALL,
    SKIP_NONE,
    SKIP_WHITESPACE
} LookaheadMode;

typedef enum {
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
}SerialConfig;

class Serial
{
private:
    uint32_t _address;

    uint32_t readReg(int reg);

public:
    Serial(uint32_t address);
    ~Serial();

    int available();
    int availableForWrite();
    void begin(long baud);
    void begin(long baud, config);
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
    size_t print(val);
    size_t print(val, format);
    size_t println(val);
    size_t println(val, format);
    int read();
    int readBytes(char buffer, int length);
    int readBytes(byte buffer, int length);
    size_t readBytesUntil(char character, char buffer, int length);
    size_t readBytesUntil(char character, byte buffer, int length);

    String readString();
    String readStringUntil(char terminator);
    void setTimeout(long time);
    size_t write(val);
    size_t write(str);
    size_t write(buf, len);
};
