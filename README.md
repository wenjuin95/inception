# Inception 🐳

## About The Project

This project demonstrates the deployment of a microservice-pattern architecture using Docker. Key features include:
- Service Isolation: Each core service runs in a dedicated container based on a custom Debian image.
- Secure Networking: Inter-container communication via a private bridge network with NGINX as the TLS-encrypted gateway.
- Persistence: Implementation of Docker volumes to ensure data integrity across container lifecycles."

### Key Features

- **Dockerized Services**: NGINX, WordPress, and MariaDB are each containerized using custom Dockerfiles based on Debian.
- **Secure Communication**: NGINX serves content exclusively over HTTPS (port 443) using a self-signed TLS v1.3 certificate.
- **Isolated Networking**: A custom bridge network ensures that containers can communicate securely with each other while being isolated from external networks.
- **Persistent Data**: Docker volumes are used to persist MariaDB database files and WordPress site content on the host machine, ensuring data is not lost when containers are recreated.
- **Automated Setup**: A `Makefile` simplifies building, starting, stopping, and cleaning the entire application stack.
- **Environment Configuration**: All sensitive information and configurations (like domain names and database credentials) are managed through an `.env` file.

## Architecture

The project follows a standard three-tier architecture:

1.  **Web Server (NGINX)**: Acts as a reverse proxy. It terminates the SSL connection and forwards incoming HTTP requests to the appropriate service. PHP requests are passed to the WordPress container via FastCGI.
2.  **Application Server (WordPress + PHP-FPM)**: Handles the application logic. It runs WordPress and uses PHP-FPM to process dynamic content. It communicates with the MariaDB container to query and store data.
3.  **Database Server (MariaDB)**: The database for the WordPress installation. It is only accessible from within the Docker network, specifically by the WordPress container.

```
       User Request
            |
            v (HTTPS: 443)
+---------------------------+
|      NGINX Container      |
| (SSL/TLS Termination)     |
+---------------------------+
            |
            v (FastCGI: 9000)
+---------------------------+      +--------------------------+
|   WordPress Container   | H--> |    MariaDB Container     |
|       (PHP-FPM)         |      |       (Port: 3306)       |
+---------------------------+      +--------------------------+
            |                                |
            v (Bind Mount)                   v (Bind Mount)
+---------------------------+      +--------------------------+
|  Host: ~/data/wordpress   |      |   Host: ~/data/mariadb   |
+---------------------------+      +--------------------------+
```

## Prerequisites

-   Docker
-   Docker Compose
-   Makefile

## Getting Started

Follow these steps to set up and run the project locally.

1.  **Clone the repository:**

    ```sh
    git clone https://github.com/wenjuin95/inception.git
    cd inception
    ```

2.  **Configure the environment:**

    Create a `.env` file by copying the example file and then fill in the required values.

    ```sh
    cp srcs/.env.example srcs/.env
    ```

    Now, edit `srcs/.env` with your preferred settings. Pay special attention to:
    - `DOMAIN_WEBSITE`: This will be your local domain (e.g., `username.42.fr`). The setup script will add this to your `/etc/hosts` file.
    - `DATA_PATH`: The absolute path on your host machine where persistent volumes for MariaDB and WordPress will be stored (e.g., `/home/user/data`).

3.  **Build and Run:**

    Use the `Makefile` to build the images and launch the services. This command may prompt for your `sudo` password to modify the `/etc/hosts` file.

    ```sh
    make
    ```

4.  **Access the Website:**

    Open your web browser and navigate to the domain you specified in your `.env` file:

    ```
    https://<your_domain_website>
    ```

    For example: `https://username.42.fr`

    You will see a browser warning about the self-signed SSL certificate, which is expected. Proceed to the site to view your WordPress installation.

## Makefile Commands

The `Makefile` provides several commands to manage the application lifecycle:

| Command | Description |
| :--- | :--- |
| `make` / `make all` | Builds the Docker images from the Dockerfiles and starts all containers. |
| `make up` | Starts the containers in detached mode without rebuilding them. |
| `make stop` | Stops all running containers. |
| `make logs` | Displays the logs from all running services. |
| `make fclean` | **(Warning: Destructive)** Stops and removes all containers, networks, volumes, and images created by this project. It also deletes the data directories (`~/data/mariadb`, `~/data/wordpress`) on the host machine. |
| `make re` | Performs a full cleanup (`fclean`) and then rebuilds and restarts everything (`all`). |

## Project Structure

```
.
├── Makefile                # Main utility for building and managing the project.
├── modify_host.sh          # Script to add the custom domain to /etc/hosts.
├── remove_host.sh          # Script to remove the custom domain from /etc/hosts.
└── srcs/
    ├── docker-compose.yml  # Defines and orchestrates all the services.
    ├── .env.example        # Template for environment variables.
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/       # MariaDB configuration files.
        │   └── tools/      # Script to initialize the database.
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/       # NGINX site configuration.
        │   └── tool/       # Script to generate the SSL certificate.
        └── wordpress/
            ├── Dockerfile
            ├── conf/       # PHP-FPM configuration.
            └── tools/      # Script to set up WordPress using wp-cli.
