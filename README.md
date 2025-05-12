# PHP-FPM Docker Image

A highly configurable PHP-FPM Docker image based on Ubuntu with Xdebug support, designed for development environments.

## Features

- Based on Ubuntu (configurable version)
- PHP support (configurable version)
- Xdebug pre-configured
- Composer included
- Symfony CLI included
- Fully configurable via environment variables
- Redis, PostgreSQL, SQLite, and MySQL support
- YAML, AMQP, and APCu extensions

## Quick Start
```
bash
# Pull the image
docker pull yourusername/php-fpm:latest
# Run with Docker
docker run -p 9000:9000 -v $(pwd):/var/www/html yourusername/php-fpm:latest
``` 

## Using with Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  php-fpm:
    image: pusachev/php-fpm:latest
    ports:
      - "9000:9000"
    volumes:
      - ./:/var/www/html
      - ./conf/php/xdebug.ini:/etc/php/8.4/mods-available/xdebug.ini
    environment:
      PHP_IDE_CONFIG: "serverName=docker"
      XDEBUG_ENABLED: "1"  # Enable Xdebug (set to 0 to disable)
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

Run with:
``` bash
docker-compose up -d
```
## Environment Configuration
The image can be configured using a file with the following variables: `.env`
``` 
# Base configuration
UBUNTU_VERSION=24.04
PHP_VERSION=8.4

# PHP configuration
PHP_MEMORY_LIMIT=756M
PHP_UPLOAD_MAX_FILESIZE=100M
PHP_POST_MAX_SIZE=100M
PHP_MAX_EXECUTION_TIME=300

# Working directory
WORKING_DIR=/var/www/html
```
## Building Customized Images
You can build your own version of the image with custom configurations:
``` bash
# Clone the repository
git clone https://github.com/pusachev/docker-php-fpm.git
cd docker-php-fpm

# Edit .env file with your preferred settings
# Then build the image
docker build -t custom-php-fpm .
```
Or specify build arguments directly:
``` bash
docker build -t custom-php-fpm \
  --build-arg UBUNTU_VERSION=22.04 \
  --build-arg PHP_VERSION=8.2 \
  --build-arg PHP_MEMORY_LIMIT=1024M \
  .
```
## Xdebug Configuration
Xdebug is pre-configured for use with PhpStorm. The default configuration is:
``` ini
xdebug.mode=debug
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.start_with_request=trigger
xdebug.discover_client_host=0
xdebug.idekey=PHPSTORM
```
You can override this configuration by mounting your own file: `xdebug.ini`
``` yaml
volumes:
  - ./my-xdebug.ini:/etc/php/8.4/mods-available/xdebug.ini
```
# Using the Build Script
The repository includes a convenient `build.sh` script that automates the process of rebuilding and pushing the PHP-FPM Docker image. This script performs the following actions:

1. Reads the PHP version from the `.env` file
2. Stops any running containers that use the image `{vendor}/php-fpm:{php-version}`
3. Removes the existing image locally
4. Rebuilds the image from the Dockerfile
5. Pushes the newly built image to Docker Hub

To use the script:

1. Make the script executable (first time only)

```bash
chmod +x build.sh
```
2. Run the script

```bash
./build.sh
```
Note: This script assumes you are already authenticated with Docker Hub. If not, run `docker login` before running the script.



## Available PHP Extensions
The image comes with the following PHP extensions pre-installed:
- fpm, cli, common
- gd, curl, intl, mbstring
- mysql, xml, zip, bcmath
- soap, xsl, sockets, opcache
- xdebug, ctype, iconv, tokenizer
- dom, simplexml, pdo, pgsql
- sqlite3, redis, apcu, amqp, yaml

## License
This project is licensed under the MIT License - see the LICENSE file for details.
## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
