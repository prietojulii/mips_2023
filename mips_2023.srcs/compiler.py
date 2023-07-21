Test = "./assembler1.txt"

Inst_R = {"sll": 0, "srl": 2, "sra": 3, "sllv": 4, "srlv": 6, "srav": 7, "addu": 33, "subu": 35, "and": 36, "or": 37, "xor": 38, "nor": 39, "slt": 42}
Inst_L_S = {"lb": 32, "lh": 33, "lw": 35, "lwu": 39, "lbu": 36, "lhu": 37, "sb": 40, "sh": 41, "sw": 43}
Inst_I =  {"addi": 8, "andi": 12, "ori": 13, "xori": 14, "lui": 15, "slti": 10, "beq": 4, "bne": 5}
Inst_J = { "j": 2, "jal": 3}
Inst_J_R = {"jr": 8, "jalr": 9}
Inst_HALT = {"halt": 63}

"""
registros = {"$zero": 0, "$at": 1, "v0": 2, "v1": 3, "a0": 4, "a1": 5, "a2": 6, "a3": 7,
			"$t0": 8, "$t1": 9, "$t2": 10, "$t3": 11, "$t4": 12, "$t5": 13, "$t6": 14, "$t7": 15, "$t10": 24, "$t9": 25,
 			"$s0": 16,"$s1": 17, "$s2": 18,"$s3": 19,"$s4": 20, "$s5": 21, "$s6": 22, "$s7": 23,
 			"$k0": 26,"$k7": 27,
 			"$gp": 28,"$sp": 29, "$fp": 30, "$ra": 31}
"""

registros = {"R0": 0, "R1": 1, "R2": 2, "R3": 3, "R4": 4, "R5": 5, "R6": 6, "R7": 7, "R8": 8, "R9": 9, "R10": 10, "R11": 11, "R12": 12,
			"R13": 13, "R14": 14, "R15": 15, "R16": 16, "R17": 17, "R18": 18, "R19": 19, "R20": 20, "R21": 21, "R22": 22, "R23": 23, "R24": 24,
			"R25": 25, "R26": 26, "R27": 27, "R28": 28, "R29": 29, "R30": 30, "R31": 31}

class assembler:

	def read_file(self):

		file   = open (Test,'r')
		string = file.read()
		file.close()
		return string

	def write_file(self, code_machine, file):		
		file.write(code_machine + "\n")
		
	def getBit(self, y, x):
		return str((x>>y)&1)

	def dec_to_bin(self, x, count=8):
		shift = range(count-1, -1, -1)
		bits = map(lambda y: initial.getBit(y, x), shift)
		return "".join(bits)

	def bin_to_hex(self, num):
		print(num)
		string = ""		
		for i in range(8):
			variable = (num[(i*4):(4*i+4)])			
			numdec = int(variable,2)
			hexade = hex(numdec).replace('0x', '')			
			string = string + hexade
		#print(string)			
		return string

	def assemble_instructionR(self, op_code, rs, rt, rd, shamp, funct):

		inst = op_code+str(rs)+str(rt)+str(rd)+shamp+str(funct)
		return inst

	def assemble_instructionI(self, op_code, rs, rt, address):

		inst = str(op_code) + str(rs) + str(rt) + str(address)
		return inst

	def assemble_instructionJ(self, op_code, address):

		inst = str(op_code) + str(address)
		return inst

	def get_instruction(self, instruction):
	
		return instruction.split(" ")


initial = assembler()

line = initial.read_file().strip()


programa = line.split("\n")
print(line)

file = open ('intruction.txt', 'w')

for item in programa:

	inst = initial.get_instruction(item)
	

	if (inst[0] in Inst_R):
		#print(inst)
		rs = initial.dec_to_bin(int(registros[inst[2].replace(',','')]), 5)
		rt = initial.dec_to_bin(registros[inst[3].replace(',','')], 5)
		rd = initial.dec_to_bin(registros[inst[1].replace(',','')], 5)
		funct = initial.dec_to_bin(Inst_R[inst[0]], 6)
		inst_ass = initial.assemble_instructionR("000000", rs, rt, rd, "00000", funct)		
		initial.write_file(initial.bin_to_hex(inst_ass), file)

	if (inst[0] in Inst_I):
		#print(inst[0])		
		op = initial.dec_to_bin(Inst_I[inst[0]],6)
		if (inst[0] == "lui"):			
			rt = initial.dec_to_bin(registros[inst[1].replace(',','')],5)
			rs = "00000"
			inm = initial.dec_to_bin(int(inst[2]), 16)
		elif (inst[0] == "beq" or inst[0] == "bne"):
			rs = initial.dec_to_bin(registros[inst[1].replace(',','')],5)
			rt = initial.dec_to_bin(registros[inst[2].replace(',','')],5)			
			inm = initial.dec_to_bin(int(inst[3]), 16)
		else:
			rs = initial.dec_to_bin(registros[inst[2].replace(',','')],5)			
			rt = initial.dec_to_bin(registros[inst[1].replace(',','')],5)		
			inm = initial.dec_to_bin(int(inst[3]), 16)

		inst_ass = initial.assemble_instructionI(op, rs, rt, inm)
		initial.write_file(initial.bin_to_hex(inst_ass), file)


		
	if (inst[0] in Inst_J_R):
		funct = initial.dec_to_bin(Inst_J_R[inst[0]], 6)
		if (inst[0] == "jalr"):
			rs = initial.dec_to_bin(registros[inst[2].replace(',','')], 5)
			rd = initial.dec_to_bin(registros[inst[1].replace(',','')], 5)
			inst_ass = initial.assemble_instructionR("000000", rs, "00000", rd, "00000", funct)		
			initial.write_file(initial.bin_to_hex(inst_ass), file)
		if (inst[0] == "jr"):
			rs = initial.dec_to_bin(registros[inst[1].replace(',','')], 5)
			inst_ass = initial.assemble_instructionR("000000", rs, "00000", "00000", "00000", funct)	
			initial.write_file(initial.bin_to_hex(inst_ass), file)

	if (inst[0] in Inst_HALT):
		op = initial.dec_to_bin(Inst_HALT[inst[0]], 6)
		inm = "0000000000000000"
		inst_ass = initial.assemble_instructionI(op, "00000", "00000", inm)
		initial.write_file(initial.bin_to_hex(inst_ass), file)


	if (inst[0] in Inst_L_S):		
		op = initial.dec_to_bin(Inst_L_S[inst[0]],6)
		rt = initial.dec_to_bin(registros[inst[1].replace(',','')], 5)			
		var1= inst[2].split('(')		
		inm =  initial.dec_to_bin(int(var1[0]), 16)		
		var2 = var1[1].replace(')','')			
		rs = initial.dec_to_bin(int(var2),5)

		inst_ass = initial.assemble_instructionI(op, rs, rt, inm)
		initial.write_file(initial.bin_to_hex(inst_ass), file)
		

	if (inst[0] in Inst_J):
		op  = initial.dec_to_bin(Inst_J[inst[0]],6)
		inm = initial.dec_to_bin(int(inst[1]), 26)
		inst_ass = initial.assemble_instructionJ(op, inm)

		initial.write_file(initial.bin_to_hex(inst_ass), file)

file.close()