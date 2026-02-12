# MISIRI Core - Núcleo RISC-V de 32 bits (Monociclo)

MISIRI es un núcleo de procesamiento **monociclo** compatible con el subconjunto RV32I de la arquitectura RISC-V.  
Está diseñado para ser **modular, determinista y fácilmente verificable**, con una filosofía de control completamente centralizada en el bloque `decode`.  
El núcleo es **estrictamente monociclo**: cada instrucción se ejecuta en un único ciclo de reloj, sin pipeline, sin forwarding y sin estados de espera.

---

## 🚀 Características

- **RV32I base** (sin extensiones, sin CSR, sin interrupciones reales).
- **Arquitectura monociclo puro**: IF, ID, EX, MEM y WB ocurren en el mismo ciclo.
- **Reset activo bajo (`rst_n`)** asíncrono, vector de arranque configurable (`boot_pc`).
- **ALU combinacional** con flags `zero`, `neg` y `carry` (carry calculado para ADD y SUB).
- **Unidad de salto (`branch_unit`)** que solo evalúa la condición; no genera direcciones.
- **Decodificador (`decode`)** que produce todas las señales de control, incluyendo `branch_type[2:0]`, `imm_type`, `alu_fn`, etc.
- **Generador de inmediatos** integrado dentro de `decode` (instancia `imm_gen`).
- **Load/Store Unit** dividida en dos módulos combinacionales:
  - `lsu_align`: alineación y extensión de signo/cero para cargas, formateo de datos para almacenamiento.
  - `lsu_bus_if`: generación de la interfaz de bus de datos (`d_addr`, `d_wdata`, `d_we`, `d_req`).
- **Interrupciones** solo como placeholder (`irq_ack = 0`), sin impacto en el flujo del programa.
- **Escritura síncrona** en el banco de registros, lecturas combinacionales.
- **Sin señales de handshake**: las memorias deben responder en el mismo ciclo (`i_rdata`, `d_rdata` siempre válidos).

---

## 📁 Estructura del Módulo Principal (`misiri_top`)

```
misiri_top
├── pc_reg                 → PC + reset con boot_pc
├── decode                 → decodificación + inmediatos
├── regfile_32x32          → banco de registros
├── alu                    → operación aritmético‑lógica + flags
├── branch_unit            → evaluación de condición de salto
├── pc_mux                 → selección del próximo PC
├── lsu_align              → alineación y extensión de datos
└── lsu_bus_if             → interfaz con bus de datos
```

---

## 📋 Señales de Control Generadas por `decode`

| Señal          | Ancho | Descripción                                                |
|----------------|-------|------------------------------------------------------------|
| `rs1`, `rs2`, `rd` | 5     | Direcciones de registros                                   |
| `alu_fn`       | 4     | Código de operación para la ALU (ver `instructions.v`)     |
| `alu_src`      | 1     | 0 → usar `rs2`, 1 → usar inmediato                         |
| `reg_write`    | 1     | Habilita escritura en el banco de registros                |
| `is_load`      | 1     | Carga desde memoria                                        |
| `is_store`     | 1     | Almacenamiento a memoria                                   |
| `lsu_size`     | 2     | Tamaño: 00=byte, 01=half, 10=word                         |
| `wb_sel`       | 2     | Selección de writeback: 00=ALU, 01=MEM, 10=PC+4           |
| `branch_type`  | 3     | Código `funct3` para la condición de salto                |
| `imm_I`        | 32    | Inmediato tipo I (para ADDI, LW, JALR)                    |
| `imm_B`        | 32    | Inmediato tipo B (para BEQ, BNE, etc.)                    |
| `imm_J`        | 32    | Inmediato tipo J (para JAL)                               |
| `is_jal`       | 1     | Instrucción JAL                                           |
| `is_jalr`      | 1     | Instrucción JALR                                          |

> **Nota**: `decode` instancia internamente `imm_gen` y genera `imm_I`, `imm_B`, `imm_J` a partir de `imm_ext`.  
> La señal `mem_signed` (para LB/LH vs LBU/LHU) está pendiente de añadir.

---

## 🧠 ALU y Flags

- **Operaciones**: suma, resta, AND, OR, XOR, desplazamientos, comparaciones con/sin signo.
- **Flags combinacionales**:
  - `flag_zero`: resultado igual a cero.
  - `flag_neg`: bit más significativo del resultado (signo).
  - `flag_carry`: acarreo en suma (ADD) o *borrow* en resta (SUB) – necesario para BLTU/BGEU.

---

## 🧭 Lógica de Próximo PC (`pc_mux`)

Prioridad RISC‑V:

1. **JALR** → `(rs1 + imm_I) & ~1`
2. **JAL**  → `PC + imm_J`
3. **Branch tomado** → `PC + imm_B`
4. **Secuencial** → `PC + 4`

---

## 💾 Interfaz con Memorias

### Bus de Instrucciones

| Señal     | Dirección | Descripción                        |
|-----------|-----------|------------------------------------|
| `i_addr`  | salida    | Dirección de instrucción (PC)      |
| `i_req`   | salida    | Petición de lectura (`core_enable`)|
| `i_rdata` | entrada   | Instrucción leída                 |

**`i_ack`** existe como puerto pero **no se utiliza** (monociclo puro).

### Bus de Datos

| Señal     | Dirección | Descripción                                    |
|-----------|-----------|------------------------------------------------|
| `d_addr`  | salida    | Dirección calculada por ALU                   |
| `d_wdata` | salida    | Dato a escribir, ya alineado por `lsu_align`  |
| `d_we`    | salida    | Byte enables generados por `lsu_bus_if`       |
| `d_req`   | salida    | `is_load | is_store`                         |
| `d_rdata` | entrada   | Dato leído de memoria                        |

**`d_ack`** existe como puerto pero **no se utiliza**.

---

## 🔄 Flujo de una Instrucción (Ciclo Único)

1. **PC** genera dirección → `i_rdata` disponible combinacionalmente.
2. **decode** produce señales de control e inmediatos.
3. **Regfile** entrega `rs1_data`, `rs2_data`.
4. **ALU** calcula resultado y flags.
5. **branch_unit** evalúa condición → `branch_taken`.
6. **pc_mux** selecciona `pc_next`.
7. **lsu_align** prepara datos de carga/almacenamiento.
8. **lsu_bus_if** genera `d_addr`, `d_wdata`, `d_we`, `d_req`.
9. **Writeback mux** selecciona dato a registrar.
10. Al flanco de reloj:
    - `pc_reg` carga `pc_next`.
    - **regfile** escribe `rd_data` si `reg_write = 1`.

Todo ocurre en **un solo ciclo**; no hay registros intermedios entre etapas.

---

## ⚙️ Convención de Reset

- **Activo bajo** (`rst_n`).
- **Asíncrono**: afecta inmediatamente a `pc_reg`.
- **Vector de arranque** configurable mediante `boot_pc`.
- El banco de registros, en la versión actual, utiliza reset activo alto (se adapta en el TOP con `~rst_n`).  
  *Se recomienda modificar `regfile_32x32` para usar `rst_n` directamente.*

---

## ⚡ Interrupciones (Placeholder)

El puerto `irq_vect` se ignora y `irq_ack` se mantiene siempre en `0`.  
No existe lógica de traps, CSRs ni desvío del PC.  
El diseño está preparado para añadir un subsistema de interrupciones en el futuro.

---

## 🧪 Programa de Prueba (Ejemplo)

La memoria de instrucciones puede cargarse con el siguiente programa para verificar operaciones básicas:

| Dirección | Instrucción        | Comentario                     |
|----------|--------------------|--------------------------------|
| 0x00     | `ADDI x1, x0, 5`   | x1 = 5                        |
| 0x04     | `ADDI x2, x0, 10`  | x2 = 10                       |
| 0x08     | `ADD  x3, x1, x2`  | x3 = 15                       |
| 0x0C     | `ADDI x4, x0, -3`  | x4 = -3                       |
| 0x10     | `SLT  x5, x4, x1`  | x5 = 1 (x4 < x1)              |
| 0x14     | `JAL  x0, 8`       | salta a 0x1C (PC+8)           |
| 0x18     | `ADDI x6, x0, 1`   | se salta                      |
| 0x1C     | `ADDI x7, x0, 2`   | x7 = 2                        |
| 0x20     | `ADD  x8, x6, x7`  | x8 = 2 (x6 sigue siendo 0)    |
| ...      | NOP                |                               |

---

## 📄 Licencia

**Creative Commons BY-NC-ND 4.0**  
- Uso no comercial.  
- No se permiten obras derivadas sin autorización explícita.  
- Atribución obligatoria al autor.

© 2025 David Alexander Ramírez Díaz  
Todos los derechos reservados.

---

## 🔮 Trabajo Futuro (Pendientes)

- Añadir señal `mem_signed` al decodificador para soportar correctamente LB/LBU, LH/LHU.
- Modificar `regfile_32x32` para usar reset activo bajo (`rst_n`) y eliminar la negación en el TOP.
- Completar el soporte de interrupciones (CSRs, trap handler, desvío de PC) si se desea salir del modo monociclo.
- Evaluar la migración a una versión **pipeline** si los requisitos de frecuencia así lo exigen.

---

**MISIRI** – Núcleo RISC-V hecho en México, con identidad y determinismo.  
Para preguntas, contribuciones o reportes, contacta al autor.