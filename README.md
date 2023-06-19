# 📚 Booktropolis: A Virtual Library Platform 🚀

Welcome to Booktropolis! This project is a virtual library management system that uses Docker, PostgreSQL, and Python. The platform provides an interactive way to manage and explore a database of books, authors, and other related entities. 

## 🚀 Getting Started

The Booktropolis project uses Docker and Docker Compose for setup and deployment. If you don't have Docker installed, please refer to the [official Docker documentation](https://docs.docker.com/get-docker/) for installation steps.

### ⬇️ Clone the Repository

First, clone this repository to your local machine using git:

    git clone https://github.com/benediktpri/booktropolis.git

Then, navigate into the project directory:

    cd Code

## 🛠️ Build and Run with Docker Compose

In the project directory, you can start the application using Docker Compose:

    docker-compose up --build

This command builds the Docker images and starts the containers. The Streamlit app should now be accessible at http://localhost:8501.

#### 🔄 Resetting the Docker Volume

If you want to start from scratch (e.g., to initialize a new database), you can delete the Docker volumes using the following command:

    docker-compose down -v

This command stops the containers and removes the volumes. Run docker-compose up --build again to recreate the volumes and start the containers.

#### 🎯 Features

    Interactive Streamlit application for data exploration
    Dockerized setup for easy deployment
    PostgreSQL database for robust data storage

#### 🧰 Technologies Used

    Docker / Docker Compose
    Python
    PostgreSQL
    Streamlit

#### 💻 Developer Notes

This project uses PostgreSQL as the database system and psycopg2 for database connections. SQLAlchemy is also compatible but not currently implemented in this [project](https://youtu.be/4d3GrayMs_o).

Enjoy exploring Booktropolis! 🎉📚
