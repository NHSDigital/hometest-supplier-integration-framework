FROM python:3.12-slim

WORKDIR /app
COPY sandbox/mock_server.py /app/sandbox/mock_server.py
COPY examples/fhir /app/examples/fhir

ENV PORT=9000
ENV BASE_PATH=
EXPOSE 9000

CMD ["python", "/app/sandbox/mock_server.py"]
