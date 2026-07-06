# 🔒 Spark_Ada_Utilities

Una suite nativa de utilidades criptográficas, manipulación segura de memoria y cálculo de entropía desarrollada en **Ada 2022** y **100% verificada formalmente** con **SPARK** bajo el nivel de prueba más estricto (`--level=4`).

## 🚀 Características y Módulos

El proyecto está estructurado de forma modular utilizando el gestor de paquetes **Alire** e inyecta validación estricta de contratos en tiempo de ejecución (`-gnata`):

*   **`Spark_Bcryptgenrandom`**: Binding seguro y robusto para la API BCrypt de Windows. Incluye un bucle de reintento ante fallos transitorios de entropía del sistema, garantizando mediante contratos que no se reintentarán errores estructurales de programación (`STATUS_INVALID_HANDLE` o `STATUS_INVALID_PARAMETER`).
*   **`Spark_Shannon_Entropy_String`**: Implementación matemática del cálculo de la entropía de Shannon para cadenas de texto. Diseñada con precondiciones matemáticas estrictas que garantizan la inmunidad total contra divisiones por cero o desbordamientos flotantes (*float overflow*).
*   **`Spark_Generate_Entropy`**: Funciones utilitarias para la recolección, mezcla y generación de entropía segura para claves criptográficas o nonces.
*   **`Spark_Handling_Lowercase` / `Uppercase`**: Funciones seguras para la manipulación y normalización de texto basadas en predicados y contratos que demuestran formalmente la ausencia de desbordamientos de buffer (*buffer overflows*).
*   **`DataType_Win32`**: Mapeo estricto y limpio de tipos de datos nativos de la API de Windows para su interoperabilidad segura con Ada/SPARK.

## 🛠️ Requisitos de Verificación Formal

Toda la lógica de bucles, invariantes y contratos funcionales de este repositorio ha sido demostrada de manera estática con un veredicto de **0 errores y 0 mediums** (100% en verde).

Debido a las complejidades intrínsecas de la teoría de punto flotante del estándar IEEE 754 presentes en el módulo de Shannon, **se requiere el uso del solver COLIBRI** (incluido nativamente en *GNAT Community 2021*) para resolver los chequeos de rango y desbordamiento flotante intermedio. Los solucionadores SMT estándar de Alire (`cvc5` o `Z3`) pueden generar alertas falsas si COLIBRI no está presente en el `PATH` del sistema.

### Comando de verificación:
```bash
\(env:PATH = "C:\GNAT\2021\bin;" + \)env:PATH
alr gnatprove --level=4 --report=all --prover=all
```

## 📦 Uso e Instalación
Al estar configurado como una librería estándar de Alire, puedes clonar este repositorio dentro de tu espacio de trabajo e integrarlo directamente en tus proyectos de Ada añadiendo la dependencia en tu manifiesto `alire.toml`.
