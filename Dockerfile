# ----------------------------
# Base Image
# ----------------------------
FROM python:3.11-slim

# Security: prevent Python from buffering logs
ENV PYTHONUNBUFFERED=1

# Create non-root user
RUN useradd -m appuser

# Set working directory
WORKDIR /app

# Install system dependencies (minimal)
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements first for caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root
USER appuser

# Expose port
EXPOSE 8004

# Run with multiple workers (production safe)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8004", "--workers", "4"]
