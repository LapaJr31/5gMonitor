FROM python:3.11-slim

WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir \
    influxdb-client==1.38.0 \
    requests==2.31.0

# Copy script
COPY collector.py .

# Make executable
RUN chmod +x collector.py

# Run with unbuffered output
CMD ["python", "-u", "collector.py"]
