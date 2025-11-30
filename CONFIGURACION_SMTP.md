# Configuración SMTP para Envío de Correos

## Pasos para configurar el envío de correos reales

### 1. Crear archivo .env
Copia el archivo `.env.example` a `.env`:
```bash
cp .env.example .env
```

### 2. Obtener contraseña de aplicación de Gmail

**IMPORTANTE:** Gmail requiere una "Contraseña de aplicación", NO tu contraseña normal.

1. Ve a tu cuenta de Google: https://myaccount.google.com/
2. Activa la **Verificación en 2 pasos** si no está activada
3. Ve a **Seguridad** > **Contraseñas de aplicaciones**
4. O directamente: https://myaccount.google.com/apppasswords
5. Selecciona "Correo" y "Otro (nombre personalizado)"
6. Escribe "RAB App" o el nombre que prefieras
7. Haz clic en "Generar"
8. **Copia la contraseña de 16 caracteres** que aparece

### 3. Configurar el archivo .env

Edita el archivo `.env` y completa con tus credenciales:

```bash
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=gmail.com
SMTP_USER_NAME=tu_email@gmail.com
SMTP_PASSWORD=xxxx xxxx xxxx xxxx  # La contraseña de aplicación de 16 caracteres (sin espacios)
```

**Nota:** Si usas la contraseña de aplicación, quita los espacios o déjalos, ambos funcionan.

### 4. Reiniciar el servidor

Después de configurar el `.env`, reinicia tu servidor Rails:
```bash
# Detén el servidor (Ctrl+C) y vuelve a iniciarlo
bin/rails server
```

### 5. Probar el envío

Intenta recuperar una contraseña nuevamente. El correo debería llegar a tu bandeja de entrada.

## Solución de problemas

- **Error de autenticación:** Verifica que estés usando una contraseña de aplicación, no tu contraseña normal
- **No llegan los correos:** Revisa la carpeta de spam
- **Error de conexión:** Verifica que el puerto 587 no esté bloqueado por tu firewall

## Volver a guardar correos en archivos

Si quieres volver a guardar los correos en archivos en lugar de enviarlos:

1. Edita `config/environments/development.rb`
2. Comenta las líneas de SMTP y descomenta las de `:file`
3. Reinicia el servidor
