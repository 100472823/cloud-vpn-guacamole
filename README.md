# 🔐 NetSecure Guacamole Access Portal

---

## 🚀 Descripción del Proyecto

Este proyecto consiste en un sistema seguro de acceso remoto basado en **Apache Guacamole**, desplegado dentro de un **contenedor LXC** sobre una infraestructura **Proxmox VE** local, protegido mediante una conexión **WireGuard VPN**, expuesto públicamente a través de un **servidor VPS** que actúa como **reverse proxy usando NGINX** con certificados SSL de **Let's Encrypt**.

El sistema incluye personalización completa del frontend, integración de autenticación de dos factores (**TOTP**), y backups externos sobre un **NAS Synology**. Ha sido diseñado desde cero con énfasis en la seguridad, la privacidad y la fiabilidad.

---

## 📚 Tecnologías Usadas (Detalladas)

- **Proxmox VE (8.x)**  
  Utilizado como hipervisor para alojar el contenedor LXC que ejecuta Guacamole. Proporciona un aislamiento seguro y ligero del entorno.

- **LXC Container (Debian 12 - Bookworm)**  
  Elegido por su ligereza y facilidad para mantener un entorno controlado. Es un contenedor no privilegiado para aumentar la seguridad.

- **Apache Guacamole 1.5.4**  
  Plataforma web que permite acceso remoto seguro a escritorios y servidores (RDP, SSH, VNC). Ejecuta sobre Tomcat 9 y usa MySQL como backend.

- **WireGuard VPN**  
  Configurado con un servidor WireGuard en un VPS público y un cliente WireGuard instalado dentro del contenedor LXC. Protege todas las conexiones internas del servidor.

- **NGINX Reverse Proxy**  
  Configurado en un servidor VPS externo, se encarga de reenviar peticiones HTTPS cifradas hacia la IP interna del contenedor vía VPN.

- **Guacamole TOTP Plugin**  
  Añade autenticación de doble factor (2FA) compatible con Google Authenticator. Incrementa enormemente la seguridad del acceso.

- **Custom Branding (branding.jar)**  
  Permite personalizar el frontend con logos, texto y estilos CSS propios. Creado y empaquetado manualmente.

- **Synology NAS (CIFS mount)**  
  Se utiliza para almacenar backups remotos del contenedor LXC, configuraciones y datos del servicio.

---

## 🧱 Arquitectura del Proyecto (Visual)

```text
Cliente Web (Usuario Final)
            |
            v
[HTTPS:443 - NGINX Reverse Proxy en VPS] 
            |
            v
[WireGuard VPN Tunnel:x.x.x.0/24]
            |
            v
[Proxmox VE Host - IP 192.168.0.X]
            |
            v
[Contenedor LXC Debian 12 - Apache Guacamole]
            |
            v
[Autenticación 2FA, Branding Personalizado, MySQL]
            |
            v
[Backups CIFS - Synology NAS en 192.168.x.x]
🚨 Problemas Técnicos Encontrados y Soluciones Aplicadas
🛑 Problema con la conexión a Internet al activar WireGuard
Al activar WireGuard, inicialmente se perdió conexión DNS e internet dentro del contenedor. Esto ocurrió porque la configuración predeterminada de WireGuard redirigía todo el tráfico a través de la interfaz VPN (wg0).

✅ Solución:

Se configuró correctamente el parámetro AllowedIPs de WireGuard para restringir únicamente el tráfico de red privada (VPN) por wg0 y mantener el tráfico público a través de eth0.

🛑 Mal uso de rutas en el servidor Guacamole (branding.jar)
En varias ocasiones, se cometió el error de colocar extensiones Java (branding.jar y guacamole-auth-totp.jar) en rutas incorrectas (/var/lib/tomcat9/webapps/...). Esto causó que no cargaran correctamente las extensiones.

✅ Solución:

Las extensiones deben ir exclusivamente en: /etc/guacamole/extensions/.

Se aprendió que no se debe modificar directamente el contenido extraído de guacamole.war.

🛑 Error en montaje CIFS hacia NAS Synology
Se produjeron problemas iniciales con la conexión CIFS desde el contenedor LXC hacia el NAS, mostrando mensajes como Permission Denied.

✅ Solución:

Instalación obligatoria del paquete cifs-utils.

Revisión de credenciales y permisos adecuados en el NAS.

Confirmación de ruta correcta del recurso compartido.

🛑 Error en 2FA (Guacamole TOTP)
Al integrar el plugin guacamole-auth-totp, inicialmente el servicio no solicitaba código 2FA o no arrancaba correctamente debido a la incorrecta ubicación del archivo .jar.

✅ Solución:

Se confirmó la correcta ubicación (/etc/guacamole/extensions/).

Reinicio correcto del servicio Tomcat usando systemctl restart tomcat.

🛑 Configuración incorrecta del Reverse Proxy (NGINX)
La URL original /guacamole/ causaba errores si se configuraba incorrectamente en NGINX (proxy_pass sin barra final).

✅ Solución:

Se configuró correctamente en NGINX con ruta completa: proxy_pass http://vpn_client_guaca_container:8080/guacamole/.

📂 Estructura de Archivos del Branding Personalizado

branding-extension/
├── css/login-override.css
├── translations/en.json
├── images/logo-placeholder.png
├── guac-manifest.json
Estos archivos fueron empaquetados con zip para crear el archivo final branding.jar.

🔐 Medidas Adicionales de Seguridad
El contenedor no está expuesto directamente a internet, accesible únicamente vía VPN.

Uso de 2FA reduce riesgo de acceso no autorizado.

HTTPS estricto (TLS 1.2+) configurado en el proxy NGINX.

💾 Estrategia de Backup
Backups manuales y automáticos realizados desde el contenedor a un NAS externo:


mount -t cifs -o username=jrojas,password=XXXXXX //local_backup_server/Privado/proxmox-projects/backups /mnt/nas-backups
Se incluyen archivos de configuración, bases de datos, branding y snapshots completos del contenedor.

📌 Aprendizajes Clave del Proyecto
Correcta segmentación del tráfico en WireGuard.

Importancia de ubicación estricta de archivos en Guacamole.

La necesidad de testear siempre conexiones CIFS.

Automatización futura recomendable para tareas recurrentes.

📈 Posibles Mejoras Futuras
Migrar eventualmente hacia contenedores Docker para mayor portabilidad.

Añadir un sistema de logs centralizado (Loki/Grafana).

Automatizar despliegue mediante Ansible.

Ampliar autenticación integrando LDAP o SAML.

👤 Autor y Contacto
Javier Rojas Garcia-Rostan
📍 Madrid, España
📧 javirojasgr@gmail.com
🔗 LinkedIn
