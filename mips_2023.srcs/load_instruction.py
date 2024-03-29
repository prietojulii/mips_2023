# Autores: Julieta Prieto y Mateo Merino.

HALT = "00000000"

instrucciones_funct_diccionario = {
    "SLL": "000000", #RD <= 'RT' << 'SA'
    "ADD": "100000", # RD <= RS + RT
    "SUB": "100010", # RD <= RS - RT
    "SRL": "000010",
    "SRA": "000011",
    "SRAV": "000111",
    "SRLV": "000110",
    "SLLV" : "000100",
    "ADDU": "100001",
    "SUBBU": "100011",
    "OR": "100101",
    "SLT": "101010",
    "NOR": "100111",
    "XOR": "100111",
    "AND" : "100100",
    "JR":"00100",
    "JALR":"001001", # Salta a la direccion por GPR(rs) y  guarda la direccion de retorno en GPR(rd) 
}

instrucciones_opcode_diccionario = {
    "ARITH": "000000",
    "LB" : "100000", # GPT(rt) <- MEM(  base(rs) + ofsset(inmediato)  )
    "LBU" : "100100",
    "LH" : "100001",
    "LHU" : "100101",
    "LWU" : "100111",
    "LW" : "100011",
    "SB":"101000", # GPR(rt) ->  MEM(  base(rs) + ofsset(inmediato)  )
    "SH":"101001",
    "SW":"101011",
    "ADDI":"001000",
    "ANDI":"001100",
    "ORI":"001101",
    "XORI":"001110",
    "LUI":"001111",
    "SLTI":"001010",
    "BEQ":"000100", # rs == rt => jump a => pc + offset(inmediato)
    "BNE":"000101",
    "J":"000010",
    "JAL":"000011",
    "DUMMY": "111111",
    "SPECIAL":"000000",
    # Agrega más instrucciones y sus códigos aquí
}
# SLTI, BEQ, BNE, J,


def generar_instruccion_mips5():
    print("Ingrese la instrucción de MIPS5: ")
    opcode = input("Ingrese el opcode: ")
    opcode = opcode.upper()
    opcode = instrucciones_opcode_diccionario[opcode]
    rs = input("Ingrese el valor de rs: ")
    rt = input("Ingrese el valor de rt: ")
    rd = input("Ingrese el valor de rd: ")
    sa = input("Ingrese el valor de sa: ")
    funct = input("Ingrese el funct: ")
    funct = funct.upper()
    funct = instrucciones_funct_diccionario[funct]
    # Aquí puedes continuar con los demás campos que necesites

    # Concatenar los campos en la instrucción completa
    instruccion_completa = opcode + rs + rt + rd + sa + funct
    instruccion_hex = hex(int(instruccion_completa, 2))[2:].zfill(8)

    return instruccion_hex


def solicitar_instrucciones():
    instrucciones = []

    while True:
        instruccion = input("Ingrese una instrucción de MIPS5 (N para mover, Q para salir): ")

        if instruccion.upper() == "N":
            instruction = generar_instruccion_mips5()
            instrucciones.append(instruction)
        elif instruccion.upper() == "Q":
            instrucciones.append(HALT)
            break
        else:
            pass

    # Escribir las instrucciones en un archivo
    with open("instrucciones.txt", "w") as archivo:
        for instruccion in instrucciones:
            archivo.write(instruccion + "\n")

    print("Instrucciones guardadas en el archivo instrucciones.txt")

# Ejemcutar
solicitar_instrucciones()
