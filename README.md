# Professional Resume System

Un sistema automático para generar CVs en formato PDF a partir de archivos Markdown con estilos CSS personalizados. Soporta múltiples idiomas y permite generar versiones en modo normal o compacto.

## 📋 Características

- ✅ **Markdown source**: CVs definidos en Markdown puro para fácil edición
- ✅ **CSS personalizado**: Estilos externos con colores (#1A1A1A, #24476B, #2F4F6F), tipografía (Aptos, 10.5pt) y márgenes A4 precisos
- ✅ **Generación automática de PDF**: Conversión a PDF usando Google Chrome headless
- ✅ **Múltiples idiomas**: Soporte para inglés (EN) y español (ES)
- ✅ **Modos de salida**: Normal y compacto para diferentes requisitos
- ✅ **Tablas de dos columnas**: Sección de skills con layout profesional sin bordes
- ✅ **Proceso build simple**: Script bash unificado

## 🗂️ Estructura de ficheros

```
professional-resume/
├── README.md                 # Este fichero
├── resume-en.md              # CV en inglés (Markdown)
├── resume-es.md              # CV en español (Markdown)
├── resume-style.css          # Estilos CSS compartidos
├── build-resume.sh           # Script de generación (bash)
├── resume-en.pdf             # CV inglés generado (salida)
└── resume-es.pdf             # CV español generado (salida)
```

## 🔧 Requisitos previos

- **macOS**: Sistema operativo
- **Pandoc 3.9+**: Convertidor de Markdown a HTML
- **Google Chrome**: Para PDF generation (Chrome headless)
- **Bash 4+**: Para ejecutar script de build

### Instalación de requisitos

```bash
# Pandoc (using Homebrew)
brew install pandoc

# Google Chrome (download from https://www.google.com/chrome/)
# o instalar via Homebrew:
brew install --cask google-chrome
```

Verificar instalación:
```bash
pandoc --version
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version
```

## 📖 Uso

### Generar PDFs

```bash
# Generar solo CV inglés
./build-resume.sh en

# Generar solo CV español
./build-resume.sh es

# Generar ambos idiomas
./build-resume.sh all

# Generar en modo compacto (menor fuente, márgenes reducidos)
./build-resume.sh en compact
./build-resume.sh es compact
./build-resume.sh all compact
```

### Ejemplo completo

```bash
# Modo normal (ambos idiomas)
./build-resume.sh all normal

# Resultado:
# - Generated resume-en.pdf (chrome mode)
# - Generated resume-es.pdf (chrome mode)
```

## 🎨 Personalización

### Modificar contenido del CV

Editar directamente los archivos `.md`:

- **resume-en.md**: Contenido en inglés
- **resume-es.md**: Contenido en español

**IMPORTANTE**: Ambos archivos deben mantener la misma estructura de secciones para consistencia. Las secciones actuales son:

1. Cabecera (nombre, puesto, contacto)
2. Professional Summary / Perfil Profesional
3. Core Skills / Competencias Clave
4. Professional Experience / Experiencia Profesional
5. Education / Formación
6. Certifications / Certificaciones
7. Languages / Idiomas

### Modificar estilos CSS

Editar `resume-style.css` para cambiar:

**Colores**:
```css
h1 { color: #1A1A1A; }              /* Nombre (negro oscuro) */
h2 { color: #24476B; }              /* Secciones (azul oscuro) */
h3 { color: #2F4F6F; }              /* Subsecciones (azul grisáceo) */
body { color: #222222; }            /* Texto (prácticamente negro) */
```

**Tipografía**:
```css
body { font-family: Aptos, system-ui, sans-serif; font-size: 10.5pt; }
h1 { font-size: 20pt; }             /* Nombre */
h2 { font-size: 11.5pt; }           /* Secciones */
```

**Márgenes de página A4**:
```css
@page { margin: 1.3cm 1.5cm; }      /* top/bottom: 1.3cm, left/right: 1.5cm */
```

**Tablas de skills** (dos columnas, sin bordes):
```css
table.skills { border-collapse: collapse; }
table.skills td { border: none; padding: 0.3rem 0; }
```

## 🔄 Proceso de generación

El script `build-resume.sh` ejecuta estos pasos:

1. **Markdown → HTML**: `pandoc <fichero.md> -s -c resume-style.css -o <fichero.html>`
   - `-s`: Genera HTML completo (standalone)
   - `-c`: Inyecta CSS en la cabecera HTML

2. **HTML → PDF**: Google Chrome headless
   ```bash
   /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
     --headless --disable-gpu --print-to-pdf="<output.pdf>" "file://<input.html>"
   ```

### ¿Por qué Chrome en lugar de LaTeX?

- ✅ Chrome respeta colores CSS y márgenes precisos
- ✅ Compatible con HTML tables para layout flexible
- ✅ Resultados visuales consistentes
- ❌ XeLaTeX ignora CSS (colores, márgenes)
- ❌ Requiere bloques de código LaTeX especiales

## 🎯 Notas técnicas

### Estructura HTML de skills

La sección de competencias usa una tabla HTML con clase `.skills`:

```html
<table class="skills">
<tr>
  <td><strong>Category 1:</strong> Items</td>
  <td><strong>Category 2:</strong> Items</td>
</tr>
</table>
```

Esta tabla se renderea como una cuadrícula de 2 columnas sin bordes.

### Centrado de cabecera

Los párrafos que siguen inmediatamente al título principal (`h1`) se centran automáticamente:

```css
h1 { text-align: center; }
h1 + p, h1 + p + p { text-align: center !important; }
p { text-align: left; }
```

Esto asegura que nombre, puesto y contacto se centren, mientras que el resto del texto está alineado a la izquierda.

### Modo compacto

El modo `compact` aplica reglas CSS adicionales en `@media print`:

```css
@media print {
  body { font-size: 9pt; }          /* Menos tamaño */
  @page { margin: 1cm; }            /* Márgenes reducidos */
}
```

Esto permite más contenido en una página.

## 📝 Ejemplo de uso real

```bash
# 1. Editar CV en inglés
vim resume-en.md

# 2. Editar CV en español
vim resume-es.md

# 3. Personalizar colores/estilos si es necesario
vim resume-style.css

# 4. Generar PDFs en modo normal
./build-resume.sh all normal

# 5. Los archivos resume-en.pdf y resume-es.pdf están listos para descargar
open resume-en.pdf
open resume-es.pdf
```

## 🐛 Solución de problemas

### Error: "pandoc: command not found"
```bash
brew install pandoc
```

### Error: "Chrome not found"
Asegúrate de que Chrome está instalado en `/Applications/Google Chrome.app`. Si está en otra ruta, edita `build-resume.sh` con la ruta correcta.

### Los colores no aparecen en el PDF
- Verifica que `resume-style.css` existe en el mismo directorio
- Comprueba que los colores están en formato hexadecimal válido
- Regenera el PDF con `./build-resume.sh`

### El layout se ve distinto en diferentes PDFs
- Este es el comportamiento esperado si cambias márgenes o fuentes
- El modo compacto intencionalmente usa fuente más pequeña
- Para obtener resultados consistentes, no modifiques `resume-style.css`

## ✅ Checklist de mantenimiento

Antes de compartir el CV:

- [ ] Ambos archivos (EN/ES) tienen la misma estructura de secciones
- [ ] Información de contacto actualizada en ambas versiones
- [ ] Experiencia y educación sincronizadas entre idiomas
- [ ] `resume-style.css` no está modificado (o cambios son intencionales)
- [ ] PDFs generados sin errores: `./build-resume.sh all normal`
- [ ] PDFs abiertos en visor para verificar formato y colores

## 📄 Especificaciones de salida

- **Formato**: PDF (A4)
- **Márgenes**: 1.3cm (superior/inferior), 1.5cm (izquierda/derecha)
- **Fuente principal**: Aptos (fallback: sistema)
- **Tamaño body**: 10.5pt
- **Tamaño título**: 20pt
- **Tamaño secciones**: 11.5pt
- **Espaçamento**: Optimizado para 1 página

---

**Última actualización**: 27 de febrero de 2026  
**Versión**: 1.0  
**Autor**: David Aguilera Romero
