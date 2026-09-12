#!/usr/bin/env python3
"""
Download all Integration Flows from a single SAP Integration Suite package.

Required environment variables:
  SAP_CLIENT_ID       - OAuth client ID from the service key
  SAP_CLIENT_SECRET   - OAuth client secret from the service key
  SAP_TOKEN_URL       - OAuth token endpoint, e.g. https://<sub>.authentication.<region>.hana.ondemand.com/oauth/token
  SAP_API_BASE_URL    - API host, e.g. https://<tenant>.<region>.hci.sap.hana.ondemand.com/api/v1
  PACKAGE_ID          - the technical ID of the package to back up

Output:
  ./iflows/<IFlowId>/  -- unzipped contents of each iFlow, one folder per iFlow
"""

import os
import sys
import zipfile
import io
import requests

REQUIRED_VARS = [
    "SAP_CLIENT_ID",
    "SAP_CLIENT_SECRET",
    "SAP_TOKEN_URL",
    "SAP_API_BASE_URL",
    "PACKAGE_ID",
]


def get_config():
    missing = [v for v in REQUIRED_VARS if not os.environ.get(v)]
    if missing:
        print(f"Missing required environment variables: {', '.join(missing)}", file=sys.stderr)
        sys.exit(1)
    return {v: os.environ[v] for v in REQUIRED_VARS}


def get_token(cfg):
    resp = requests.post(
        cfg["SAP_TOKEN_URL"],
        auth=(cfg["SAP_CLIENT_ID"], cfg["SAP_CLIENT_SECRET"]),
        data={"grant_type": "client_credentials"},
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json()["access_token"]


def list_iflows(cfg, token, package_id):
    """List Integration Flows inside the given package via the package's navigation property."""
    url = (
        f"{cfg['SAP_API_BASE_URL']}/IntegrationPackages('{package_id}')"
        f"/IntegrationDesigntimeArtifacts?$format=json"
    )
    headers = {"Authorization": f"Bearer {token}", "Accept": "application/json"}
    resp = requests.get(url, headers=headers, timeout=30)
    resp.raise_for_status()
    data = resp.json()
    # OData v2 wraps results under d.results
    return data.get("d", {}).get("results", [])


def download_iflow(cfg, token, iflow_id, version="active"):
    """Download one iFlow's content as a zip (bytes)."""
    url = (
        f"{cfg['SAP_API_BASE_URL']}/IntegrationDesigntimeArtifacts"
        f"(Id='{iflow_id}',Version='{version}')/$value"
    )
    headers = {"Authorization": f"Bearer {token}"}
    resp = requests.get(url, headers=headers, timeout=60)
    resp.raise_for_status()
    return resp.content


def main():
    cfg = get_config()
    package_id = cfg["PACKAGE_ID"]

    print(f"Fetching token...")
    token = get_token(cfg)

    print(f"Listing iFlows in package '{package_id}'...")
    iflows = list_iflows(cfg, token, package_id)

    if not iflows:
        print("No iFlows found in this package. Check the PACKAGE_ID and role permissions.")
        return

    out_root = os.path.join(os.getcwd(), "iflows")
    os.makedirs(out_root, exist_ok=True)

    for artifact in iflows:
        iflow_id = artifact.get("Id")
        iflow_name = artifact.get("Name", iflow_id)
        print(f"Downloading '{iflow_name}' ({iflow_id})...")

        try:
            content = download_iflow(cfg, token, iflow_id)
        except requests.HTTPError as e:
            print(f"  Failed to download {iflow_id}: {e}", file=sys.stderr)
            continue

        target_dir = os.path.join(out_root, iflow_id)
        os.makedirs(target_dir, exist_ok=True)

        try:
            with zipfile.ZipFile(io.BytesIO(content)) as zf:
                zf.extractall(target_dir)
            print(f"  Extracted to {target_dir}")
        except zipfile.BadZipFile:
            # Fall back to saving the raw file if it wasn't a zip for some reason
            raw_path = os.path.join(target_dir, f"{iflow_id}.raw")
            with open(raw_path, "wb") as f:
                f.write(content)
            print(f"  Response wasn't a zip, saved raw bytes to {raw_path}", file=sys.stderr)

    print("Done.")


if __name__ == "__main__":
    main()
