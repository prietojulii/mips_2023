# MIPS
## Requerimientos
 - Windows 11
 - Vivado xilinx 2022.2
 - python 3.11
 - Basys3
 - Tener instalado [Vivado Board Basys3](https://github.com/Digilent/vivado-boards)

## Instalación
- Clone el proyecto:
    ```bash
    git clone git@github.com:prietojulii/mips_2023.git
    ```
- Abra Vivado y seleccione **Open Proyect**.
- Seleccione el archivo [mips_2023.xpr](./mips_2023.xpr) y luego NEXT.

- **Sintetice** el Proyecto y **Genere el Bitstream** desde vivado.
- Conecte la placa a su computadora con un cable micro USB.
- Selecciones `open Target` y luego `auto conect`.
- Programe la placa con `program device`.
- Abra una consola en la raiz del proyecto mips_2023.
- Ejecute:
    ```bash 
    cd mips_2023.srcs
    ```

# Ejecución
- Revise las variables de configuración en cada módulo y setee los valores que necesite para obtener los tamaños de buffer adecuados a su programa.
- Cargue el programa que desee en lenguaje ensamblador en el archivo [assembler1.txt](./MIPS_2023.srcs/compiler.py) y luego ejecute el compilador:
    ```bash
    python compiler.py
    ```
- Ejecute el programa:
    ```bash
    python program.py
    ```

**Nota**:
Puede Obtener mas información haciendo click en el siguiente [INFORME](./docs/INFORMEMIPS.html).
Se sugiere abrirlo desde un browser.
