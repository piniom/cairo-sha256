# Dane wejściowe
input1 = [1116817520, 422240787, 1662807528, 1125009420, 2870063497, 4277081908, 155536151, 2335009955]
input2 =  [66, 145, 72, 112, 25, 42, 226, 19, 99, 28, 109, 232, 67, 14, 72, 12, 171, 17, 177, 137, 254, 239, 23, 52, 9, 69, 75, 23, 139, 45, 108, 163]

# Konwersja z 32-bitowego na 8-bitowy (Little-endian)
def convert_32bit_to_8bit_little_endian(number):
    byte1 = number & 0xFF           # Pobierz najmłodszy bajt (ostatnie 8 bitów)
    byte2 = (number >> 8) & 0xFF    # Pobierz trzeci bajt (kolejne 8 bitów)
    byte3 = (number >> 16) & 0xFF   # Pobierz drugi bajt (kolejne 8 bitów)
    byte4 = (number >> 24) & 0xFF   # Pobierz najstarszy bajt (najstarsze 8 bitów)
    
    return [byte1, byte2, byte3, byte4]

# Konwersja z 32-bitowego na 8-bitowy (Big-endian)
def convert_32bit_to_8bit_big_endian(number):
    byte1 = (number >> 24) & 0xFF   # Pobierz najstarszy bajt (najstarsze 8 bitów)
    byte2 = (number >> 16) & 0xFF   # Pobierz drugi bajt (kolejne 8 bitów)
    byte3 = (number >> 8) & 0xFF    # Pobierz trzeci bajt (kolejne 8 bitów)
    byte4 = number & 0xFF           # Pobierz najmłodszy bajt (ostatnie 8 bitów)
    return [byte1, byte2, byte3, byte4]

# Konwersja z 8-bitowego na 32-bitowy (Little-endian)
def convert_8bit_to_32bit_little_endian(byte_list):
    if len(byte_list) != 4:
        raise ValueError("Lista bajtów musi zawierać dokładnie 4 elementy")
    byte1, byte2, byte3, byte4 = byte_list
    number = (byte4 << 24) | (byte3 << 16) | (byte2 << 8) | byte1
    return number

# Konwersja z 8-bitowego na 32-bitowy (Big-endian)
def convert_8bit_to_32bit_big_endian(byte_list):
    if len(byte_list) != 4:
        raise ValueError("Lista bajtów musi zawierać dokładnie 4 elementy")
    byte1, byte2, byte3, byte4 = byte_list
    number = (byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4
    return number

# Przykład konwersji z 32-bitowego na 8-bitowy (Little-endian)
for number in input1:
    byte_list = convert_32bit_to_8bit_little_endian(number)
    print(f"Liczba 32-bitowa: {number} --> Bajty 8-bitowe (Little-endian): {byte_list}")
print()
# Przykład konwersji z 32-bitowego na 8-bitowy (Big-endian)
for number in input1:
    byte_list = convert_32bit_to_8bit_big_endian(number)
    print(f"Liczba 32-bitowa: {number} --> Bajty 8-bitowe (Big-endian): {byte_list}")
print()
# Przyprint()kład konwersji z 8-bitowego na 32-bitowy (Little-endian)
byte_list_little_endian = input2[:4]  # Weź pierwsze 4 bajty z input2
number_little_endian = convert_8bit_to_32bit_little_endian(byte_list_little_endian)
print(f"Bajty 8-bitowe (Little-endian): {byte_list_little_endian} --> Liczba 32-bitowa: {number_little_endian}")
print()
# Przykład konwersji z 8-bitowego na 32-bitowy (Big-endian)
byte_list_big_endian = input2[:4]  # Weź pierwsze 4 bajty z input2
number_big_endian = convert_8bit_to_32bit_big_endian(byte_list_big_endian)
print(f"Bajty 8-bitowe (Big-endian): {byte_list_big_endian} --> Liczba 32-bitowa: {number_big_endian}")