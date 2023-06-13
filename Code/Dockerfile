# Build stage
FROM python:slim-buster AS builder
WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Final stage
FROM python:slim-buster
WORKDIR /app

COPY --from=builder /usr/local /usr/local
COPY . .

EXPOSE 8501

CMD ["streamlit", "run", "app.py"]
