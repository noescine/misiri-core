# MISIRI Core - Núcleo RISC de 32 bits

MISIRI es un núcleo de procesamiento de propósito general basado en arquitectura RISC monociclo de 32 bits, desarrollado completamente en español y con identidad mexicana. Está diseñado para ser **modular, determinista y fácil de verificar**, inspirado en arquitecturas RV32I y proyectos previos como SARABI, pero con un conjunto de instrucciones minimalista y controlado completamente desde `decode` y `control_unit`.

---

## 🧱 Pipeline MISIRI v1

El pipeline tiene **3 etapas deterministas**:

| Etapa | Función | Señales clave |
|-------|---------|---------------|
| **IF (Instruction Fetch)** | Mantener PC, leer instrucción desde memoria, calcular PC+4 | `pc_if`, `instr_if`, `pc_next`, `if_valid` |
| **ID (Decode / Register Read)** | Decodificar instrucción RV32I, leer registros rs1 y rs2, generar señales de control | `alu_op`, `alu_src_a`, `alu_src_b`, `reg_write`, `mem_read`, `mem_write`, `wb_sel`, `branch_type`, `imm_type` |
| **EX/WB (Execute / Writeback)** | Ejecutar ALU, acceder a memoria (Load/Store Unit), escribir resultados | `alu_result`, `mem_data`, `wb_data` |

**Filosofía de diseño:**

- Sin forwarding complejo  
- Stalls explícitos  
- Determinista y verificable  
- Todo controlado desde decode + control_unit  

---

## 📋 Decode RV32I (MISIRI v1)

Campos de instrucción:

| Campo  | Bits  |
|--------|-------|
| opcode | [6:0] |
| rd     | [11:7]|
| funct3 | [14:12]|
| rs1    | [19:15]|
| rs2    | [24:20]|
| funct7 | [31:25]|

Señales de control:

| Señal        | Descripción                              |
|--------------|------------------------------------------|
| `alu_op`     | Operación de la ALU                       |
| `alu_src_a`  | Fuente A: PC o rs1                        |
| `alu_src_b`  | Fuente B: rs2 o inmediato                 |
| `reg_write`  | Habilita escritura en rd                   |
| `mem_read`   | Lectura desde memoria                     |
| `mem_write`  | Escritura a memoria                        |
| `wb_sel`     | Selección writeback: ALU / MEM / PC+4    |
| `branch_type`| Tipo de branch                            |
| `imm_type`   | Tipo de inmediato                         |

---

### 🧮 Tabla de decode principal

| Instrucción | Opcode   | alu_op | srcA | srcB | regW | memR | memW | wb_sel | branch | imm_type |
|-------------|----------|--------|------|------|------|------|------|--------|--------|----------|
| ADD         | 0110011  | ADD    | rs1  | rs2  | 1    | 0    | 0    | ALU    | NONE   | —        |
| SUB         | 0110011  | SUB    | rs1  | rs2  | 1    | 0    | 0    | ALU    | NONE   | —        |
| ADDI        | 0010011  | ADD    | rs1  | imm  | 1    | 0    | 0    | ALU    | NONE   | IMM_I    |
| LW          | 0000011  | ADD    | rs1  | imm  | 1    | 1    | 0    | MEM    | NONE   | IMM_I    |
| SW          | 0100011  | ADD    | rs1  | imm  | 0    | 0    | 1    | —      | NONE   | IMM_S    |
| BEQ         | 1100011  | SUB    | rs1  | rs2  | 0    | 0    | 0    | —      | BEQ    | IMM_B    |
| JAL         | 1101111  | ADD    | PC   | imm  | 1    | 0    | 0    | PC+4   | JUMP   | IMM_J    |

---

### 📌 Tipos de inmediato (`imm_type`)
- `IMM_I` → ADDI, LW  
- `IMM_S` → SW  
- `IMM_B` → BEQ  
- `IMM_J` → JAL  
- `IMM_U` → LUI (para futuras versiones)

---

## 🛠 Mini programa de prueba

La memoria de instrucciones (`imem`) contiene un programa de prueba que valida:

- operaciones aritméticas
- branching
- jumps
- generación de inmediatos

| Index | Instrucción           | Descripción                      |
|-------|----------------------|----------------------------------|
| 0     | `ADDI x1, x0, 5`     | x1 = 5                           |
| 1     | `ADDI x2, x0, 10`    | x2 = 10                          |
| 2     | `ADD x3, x1, x2`     | x3 = 15                          |
| 3     | `ADDI x4, x0, -3`    | x4 = -3                          |
| 4     | `SLT x5, x4, x1`     | x5 = 1 si x4 < x1, else 0       |
| 5     | `JAL x0, 8`          | Salta a instrucción 7            |
| 6     | `ADDI x6, x0, 1`     | Se saltará                       |
| 7     | `ADDI x7, x0, 2`     | x7 = 2                           |
| 8     | `ADD x8, x6, x7`     | x8 = x6 + x7 = 2                 |
| resto | NOP                  | No operación                     |

---

## 🔧 Verificación

- Simulación con Verilog (ModelSim / Vivado)  
- Vector de prueba de instrucciones manual  
- Verificación flanco a flanco de señales: `pc_out`, `instr_out`, `imm_ext`, `alu_result`  
- Test de branching y jumps  
- Validación de immediatos generados (`imm_gen`)  

---

## 🚀 Filosofía de diseño

- Núcleo **determinista** y fácil de verificar  
- Pipeline simple de 3 etapas  
- Sin forwarding complejo, stalls explícitos  
- Modular y escalable, preparado para extensiones futuras (FPU, cache, interrupciones)  
- Ideal para implementación **FPGA o ASIC**  

---

## 📄 Licencia

- Creative Commons BY-NC-ND 4.0  
- Prohibido uso comercial  
- No se permiten derivados ni implementaciones sin autorización  
- Atribución obligatoria al autor  

© 2025 David Alexander Ramírez Díaz  
Todos los derechos reservados
