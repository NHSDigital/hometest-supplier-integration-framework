import json
import logging
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse


ROOT = Path(__file__).resolve().parents[1]
FHIR_EXAMPLES = ROOT / "examples" / "fhir"
BASE_PATH = os.getenv("BASE_PATH", "").rstrip("/")


def load_json(path):
    with path.open(encoding="utf-8") as file:
        return json.load(file)


def result_response():
    searchset = load_json(FHIR_EXAMPLES / "get_test_results_non_reactive.example.json")
    return searchset["entry"][0]["resource"]


TASK_RESPONSE = load_json(FHIR_EXAMPLES / "task_update_dispatched.example.json")

BAD_REQUEST = {
    "resourceType": "OperationOutcome",
    "issue": [
        {
            "severity": "error",
            "code": "invalid",
            "details": {"text": "Validation Error"},
            "diagnostics": "Sandbox bad-request scenario requested",
        }
    ],
}

NOT_FOUND = {
    "resourceType": "OperationOutcome",
    "issue": [
        {
            "severity": "error",
            "code": "not-found",
            "details": {"text": "Resource Not Found"},
            "diagnostics": "Sandbox not-found scenario requested",
        }
    ],
}


class SandboxHandler(BaseHTTPRequestHandler):
    server_version = "HomeTestSandbox/1.0"

    def do_GET(self):
        parsed = urlparse(self.path)
        path = self.normalise_path(parsed.path)
        if path in ("/_status", "/_ping"):
            self.send_json(200, {"status": "pass"}, "application/json")
            return

        self.send_json(404, NOT_FOUND)

    def do_POST(self):
        length = int(self.headers.get("Content-Length", "0"))
        if length:
            self.rfile.read(length)

        parsed = urlparse(self.path)
        path = self.normalise_path(parsed.path)
        query = parse_qs(parsed.query)
        scenario = query.get(
            "scenario", [self.headers.get("X-Sandbox-Scenario", "success")]
        )[0]

        logging.info(
            "request method=POST path=%s scenario=%s correlation_id=%s",
            path,
            scenario,
            self.headers.get("X-Correlation-ID"),
        )

        if path == "/result":
            self.handle_result(scenario)
            return

        if path == "/test-order/status":
            self.handle_status(scenario)
            return

        self.send_json(404, NOT_FOUND)

    def normalise_path(self, path):
        if BASE_PATH and path.startswith(f"{BASE_PATH}/"):
            return path[len(BASE_PATH):]
        if BASE_PATH and path == BASE_PATH:
            return "/"
        return path

    def handle_result(self, scenario):
        if scenario in ("bad-request", "invalid"):
            self.send_json(400, BAD_REQUEST)
            return

        self.send_json(201, result_response())

    def handle_status(self, scenario):
        if scenario in ("bad-request", "invalid"):
            self.send_json(400, BAD_REQUEST)
            return

        if scenario == "not-found":
            self.send_json(404, NOT_FOUND)
            return

        self.send_json(200, TASK_RESPONSE)

    def send_json(self, status, body, content_type="application/fhir+json"):
        payload = json.dumps(body, separators=(",", ":")).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format, *args):
        logging.info("%s - %s", self.address_string(), format % args)


def main():
    logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO").upper())
    port = int(os.getenv("PORT", "9000"))
    server = ThreadingHTTPServer(("", port), SandboxHandler)
    logging.info("HomeTest sandbox listening on port %s", port)
    server.serve_forever()


if __name__ == "__main__":
    main()
