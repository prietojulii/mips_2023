'''
Este programa sirve para cargar un archivo de instrucciones en el MIPS y ejecutarlo en modo continuo o paso a paso.
Las instrucciones deben estar en un archivo de texto llamado "instrucciones.txt" en el mismo directorio que este programa.
Modo de ejecución:
    1. Conectar el MIPS a la PC mediante el puerto UART
    2. Crear un entrono virtual de Python (opcional):
        - (Crear) python -m venv entorno_mips
        - (activar) entorno_mips\bin\activate
    3. Instalar dependencias: pip install -r requirements.txt 
    4. Ejecutar el programa: python mips_program.py
'''
import signal
import sys
import serial

global ser

#SEÑALES
# Función de manejo de la señal de interrupción
def signal_handler(signal, frame):
    print("\nPrograma terminado por Ctrl+C")
    # Cerrar la conexión del puerto serial
    ser.close()
    sys.exit(0)

# Asociar la función de manejo de señal al evento de Ctrl+C
signal.signal(signal.SIGINT, signal_handler)

#PROGRAMA
# Configuración del puerto serial
uart_port = "COM8"  # Reemplaza esto con el puerto UART correspondiente en tu sistema
baud_rate = 9600  # Velocidad de transmisión en baudios

# Abrir la conexión del puerto serial
ser = serial.Serial(uart_port, baud_rate)

# Paso 1: Cargar instrucciones
print("Para empezar, presione 'L' para cargar las instrucciones.")
user_input = input("Ingrese su opción: ")

if user_input.upper() == "L":
    # Enviar comando de carga de instrucciones (0x01)
    ser.write(b'\x01')

    # Leer el archivo de instrucciones
    filename = "instrucciones.txt"  # Reemplaza esto con el nombre de tu archivo de instrucciones
    with open(filename, 'r') as file:
        for line in file:
            # Obtener la instrucción de la línea y convertirla a una cadena de bytes de 4 bytes (32 bits)
            instruction = bytes.fromhex(line.strip())
            instruction_bigendian = instruction[::-1]
            instruction_bytes = instruction_bigendian
            
            # Enviar la instrucción por UART
            ser.write(instruction_bytes)

# Paso 2: Modo continuo o paso a paso
print("Presione 'C' para modo continuo o 'S' para modo step-by-step.")
user_input = input("Ingrese su opción: ")

if user_input.upper() == "C":
    # Enviar comando de modo continuo (0x02)
    ser.write(b'\x02')
    print("Modo continuo activado.")
    print("Presione 'E' para salir.")
    
    # Esperar hasta que se presione 'E' para salir
    while True:
        user_input = input("Ingrese su opción: ")
        
        if user_input.upper() == "E":
            # Enviar comando de salida (0x05)
            # ser.write(b'\x05')
            break
            
elif user_input.upper() == "S":
    # Enviar comando de modo paso a paso (0x03)
    ser.write(b'\x03')
    print("Modo paso a paso activado.")
    print("Presione 'N' para ejecutar la próxima instrucción o 'E' para salir.")
    
    # Esperar hasta que se presione 'E' para salir
    while True:
        user_input = input("Ingrese su opción: ")
        
        if user_input.upper() == "N":
            # Enviar comando de ejecutar próxima instrucción (0x04)
            ser.write(b'\x04')
            
            # Esperar y leer la respuesta del MIPS
            response_bytes = ser.read(40)
            response_reorder = response_bytes[::-1] # ordenar los bytes big-endian
            response_hex =  response_reorder.hex()
            print("DATA A: ", response_hex[0:8])
            print("DATA B: ", response_hex[8:16])
            print("ALU Result: ", response_hex[16:24])
            print("WB data: ", response_hex[24:32])
            print("MEM to REG: ", response_hex[32:40])
            print("Selector ADDR WRITEBACK(CONTROL)(IDEX): ",response_hex[40:48] )
            print("FLAG HAY WB: ",response_hex[48:56] )
            print("Addr WB (mux):  ",response_hex[56:64] )
            print("Addr WB (1er latch):  ",response_hex[64:72] )
            print("Addr WB (en MEM reg):  ",response_hex[72:80] )

            response_bin = bin(int(response_reorder.hex(), 16))[2:].zfill(160) # convertir a binario
            # print("FLAG MEM TO REG: ", response_hex[32:40])
            print("FLAG MEM TO REG: ", response_bin[128:160])
            print("Selector Addr WB: ", response_bin[160:182])

            print("Respuesta del MIPS:",  response_reorder.hex())
            
        elif user_input.upper() == "E":
            # Enviar comando de salida (0x05)
            # ser.write(b'\x05')
            break

# Cerrar la conexión del puerto serial
ser.close()