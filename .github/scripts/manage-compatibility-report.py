#!/usr/bin/env python3
"""
manage-compatibility-report.py

Automations for Steam Headless Compatibility Reports:
1. Reopens closed compatibility reports when a new comment is added.
2. Validates Host OS version against minimum supported requirements in
   .github/config/compatibility-config.json.
3. Sanitizes and updates the issue body with clean numeric version strings.
4. Formats and standardizes the issue title for searchability:
   "[Compatibility]: <OS> | <GPU Vendor> <GPU Model>"
5. Automatically applies matching COMPAT-REPORT dimension labels from labels.json regex.
6. Searches for existing related compatibility reports (same OS + GPU vendor + model)
   and posts a cross-linking comment referencing related issues.
"""

import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request


def github_api_request(url, method="GET", data=None, token=None):
    headers = {
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "steam-headless-automation",
    }
    if token:
        headers["Authorization"] = f"token {token}"

    req_data = None
    if data is not None:
        headers["Content-Type"] = "application/json"
        req_data = json.dumps(data).encode("utf-8")

    req = urllib.request.Request(url, data=req_data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            content = resp.read().decode("utf-8")
            return json.loads(content) if content else None
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8")
        print(f"API Error [{e.code}] on {method} {url}: {err_body}", file=sys.stderr)
        raise


def extract_heading_value(body, heading_names):
    if not body:
        return None
    if isinstance(heading_names, str):
        heading_names = [heading_names]

    lines = body.splitlines()
    targets = [f"### {h.strip().lower()}" for h in heading_names]
    in_section = False
    section_lines = []

    for line in lines:
        stripped = line.strip()
        if stripped.lower() in targets:
            in_section = True
            continue
        elif in_section and stripped.startswith("### "):
            break
        elif in_section:
            section_lines.append(stripped)

    val = "\n".join(section_lines).strip()
    return val if val else None


def replace_heading_value(body, heading_names, new_value):
    if not body:
        return body
    if isinstance(heading_names, str):
        heading_names = [heading_names]

    lines = body.splitlines()
    targets = [f"### {h.strip().lower()}" for h in heading_names]

    in_target = False
    new_lines = []

    for line in lines:
        stripped = line.strip().lower()
        if stripped in targets:
            in_target = True
            new_lines.append(line)
            new_lines.append(new_value)
            continue
        elif in_target and line.strip().startswith("### "):
            in_target = False
            new_lines.append(line)
        elif in_target:
            continue
        else:
            new_lines.append(line)

    return "\n".join(new_lines)


def parse_numeric_version(v_str):
    if not v_str:
        return None
    # Extract leading/embedded version sequence (e.g. "13.1", "7.3.2", "25.10.7", "24.04.1")
    m = re.search(r"\b(\d+(?:\.\d+)*)\b", v_str)
    return m.group(1) if m else None


def parse_version_tuple(v_str):
    if not v_str:
        return ()
    parts = re.findall(r"\d+", v_str)
    return tuple(int(p) for p in parts)


def is_version_gte(v_test_str, v_min_str):
    t_test = parse_version_tuple(v_test_str)
    t_min = parse_version_tuple(v_min_str)
    if not t_test or not t_min:
        return False
    max_len = max(len(t_test), len(t_min))
    padded_test = t_test + (0,) * (max_len - len(t_test))
    padded_min = t_min + (0,) * (max_len - len(t_min))
    return padded_test >= padded_min


def normalize_gpu_model(model_str):
    if not model_str:
        return ""
    s = model_str.lower()
    s = re.sub(r"\b(nvidia|amd|intel|geforce|radeon|graphics|arc|uhd|iris|hd|pro|edition)\b", "", s)
    s = re.sub(r"[^a-z0-9]", "", s)
    return s.strip()


def gpu_models_match(model_a, model_b):
    if not model_a or not model_b:
        return False
    norm_a = normalize_gpu_model(model_a)
    norm_b = normalize_gpu_model(model_b)
    if not norm_a or not norm_b:
        return False
    if norm_a == norm_b:
        return True
    return bool(norm_a in norm_b or norm_b in norm_a)


def load_compatibility_config(repo_root):
    config_path = os.path.join(repo_root, ".github", "config", "compatibility-config.json")
    if os.path.exists(config_path):
        with open(config_path, encoding="utf-8") as f:
            return json.load(f)
    return {}


def load_label_definitions(repo_root):
    labels_path = os.path.join(repo_root, ".github", "config", "labels.json")
    if os.path.exists(labels_path):
        with open(labels_path, encoding="utf-8") as f:
            return json.load(f)
    fallback_path = os.path.join(repo_root, ".github", "labels.json")
    if os.path.exists(fallback_path):
        with open(fallback_path, encoding="utf-8") as f:
            return json.load(f)
    return []


def handle_issue_comment(owner, repo, issue_number, token):
    api_base = f"https://api.github.com/repos/{owner}/{repo}"
    issue = github_api_request(f"{api_base}/issues/{issue_number}", token=token)
    labels = [lbl["name"] for lbl in issue.get("labels", [])]

    if "type:compatibility" in labels and issue.get("state") == "closed":
        print(f"Reopening closed compatibility report #{issue_number} following new comment.")
        github_api_request(
            f"{api_base}/issues/{issue_number}",
            method="PATCH",
            data={"state": "open"},
            token=token,
        )
        if "state:stale" in labels:
            try:
                github_api_request(
                    f"{api_base}/issues/{issue_number}/labels/state:stale",
                    method="DELETE",
                    token=token,
                )
            except Exception as e:
                print(f"Could not remove state:stale label: {e}")


def handle_compatibility_issue(owner, repo, issue_number, token, repo_root):
    api_base = f"https://api.github.com/repos/{owner}/{repo}"
    issue = github_api_request(f"{api_base}/issues/{issue_number}", token=token)

    body = issue.get("body", "")
    existing_labels = [lbl["name"] for lbl in issue.get("labels", [])]

    # Extract fields from issue markdown body (handling current and legacy headings)
    os_raw = extract_heading_value(body, ["Host Operating System"])
    os_ver_raw = extract_heading_value(body, ["Host OS Version", "Host OS Version / Release"])
    gpu_vendor_raw = extract_heading_value(body, ["GPU Vendor", "GPU Manufacturer / Vendor"])
    gpu_model_raw = extract_heading_value(body, ["GPU Model"])
    deployment_mode_raw = extract_heading_value(body, ["Deployment Mode"])
    overall_status_raw = extract_heading_value(body, ["Overall Compatibility Result", "Overall Result"])

    if not (os_raw and gpu_vendor_raw and gpu_model_raw):
        print(f"Issue #{issue_number} is missing core compatibility form fields. Skipping.")
        return

    os_val = os_raw.split("\n")[0].strip()
    gpu_vendor_val = gpu_vendor_raw.split("\n")[0].strip()
    gpu_model_val = gpu_model_raw.split("\n")[0].strip()
    deployment_mode_val = deployment_mode_raw.split("\n")[0].strip() if deployment_mode_raw else ""
    overall_status_val = overall_status_raw.split("\n")[0].strip() if overall_status_raw else ""
    os_clean = re.sub(r"\s*\([^)]*\)", "", os_val).strip()

    # Load configuration
    compat_config = load_compatibility_config(repo_root)
    supported_os_map = compat_config.get("supported_os", {})

    # 1. Version Validation & Sanitization
    numeric_ver = parse_numeric_version(os_ver_raw) if os_ver_raw else None
    os_policy = supported_os_map.get(os_clean)

    if os_policy:
        min_ver = os_policy.get("min_version")
        if not numeric_ver or not is_version_gte(numeric_ver, min_ver):
            print(f"OS version '{os_ver_raw}' is below required minimum '{min_ver}' for {os_clean}.")

            # Add invalid label and close issue with explanatory message
            if "invalid:support" not in existing_labels:
                github_api_request(
                    f"{api_base}/issues/{issue_number}/labels",
                    method="POST",
                    data={"labels": ["invalid:support"]},
                    token=token,
                )

            comments = github_api_request(f"{api_base}/issues/{issue_number}/comments", token=token) or []
            already_warned = any("<!-- automated-version-validation -->" in c.get("body", "") for c in comments)

            if not already_warned:
                warn_msg = (
                    "<!-- automated-version-validation -->\n"
                    "### ⚠️ Unsupported Host OS Version\n\n"
                    f"**Steam Headless V2** requires **{os_clean} {min_ver} or higher**.\n\n"
                    f"The version provided (`{os_ver_raw}`) is below our minimum supported threshold.\n\n"
                    "This compatibility report is being closed. If you upgrade to a supported release, "
                    "please feel free to submit a new compatibility report or join our "
                    "[Discord Community](https://streamingtech.co.nz/discord) for support."
                )
                github_api_request(
                    f"{api_base}/issues/{issue_number}/comments",
                    method="POST",
                    data={"body": warn_msg},
                    token=token,
                )

            # Close issue
            github_api_request(
                f"{api_base}/issues/{issue_number}",
                method="PATCH",
                data={"state": "closed"},
                token=token,
            )
            return

    # 2. Sanitize Issue Body (if numeric version extracted cleanly and differs from raw input)
    if numeric_ver and os_ver_raw and numeric_ver != os_ver_raw.strip():
        sanitized_body = replace_heading_value(
            body,
            ["Host OS Version", "Host OS Version / Release"],
            numeric_ver,
        )
        if sanitized_body != body:
            print(f"Sanitizing issue #{issue_number} body with clean version '{numeric_ver}'")
            github_api_request(
                f"{api_base}/issues/{issue_number}",
                method="PATCH",
                data={"body": sanitized_body},
                token=token,
            )
            body = sanitized_body

    # 3. Update Title for searchability
    expected_title = f"[Compatibility]: {os_clean} | {gpu_vendor_val} {gpu_model_val}"
    current_title = issue.get("title", "")
    if current_title != expected_title:
        print(f"Updating issue #{issue_number} title to: '{expected_title}'")
        github_api_request(
            f"{api_base}/issues/{issue_number}",
            method="PATCH",
            data={"title": expected_title},
            token=token,
        )

    # 4. Match and update labels based on labels.json definitions
    label_defs = load_label_definitions(repo_root)
    target_labels = {"type:compatibility"}
    labels_to_remove = []

    for label_def in label_defs:
        name = label_def.get("name", "")
        desc = label_def.get("description", "")
        if name.startswith("COMPAT-REPORT OS:") and desc.startswith("^"):
            try:
                if re.search(desc, os_clean, re.IGNORECASE):
                    target_labels.add(name)
                elif name in existing_labels:
                    labels_to_remove.append(name)
            except re.error:
                pass
        elif name.startswith("COMPAT-REPORT GPU:") and desc.startswith("^"):
            try:
                if re.search(desc, gpu_vendor_val, re.IGNORECASE):
                    target_labels.add(name)
                elif name in existing_labels:
                    labels_to_remove.append(name)
            except re.error:
                pass
        elif name.startswith("COMPAT-REPORT MODE:") and desc.startswith("^") and deployment_mode_val:
            try:
                if re.search(desc, deployment_mode_val, re.IGNORECASE):
                    target_labels.add(name)
                elif name in existing_labels:
                    labels_to_remove.append(name)
            except re.error:
                pass
        elif name.startswith("COMPAT-REPORT RESULT:") and desc.startswith("^") and overall_status_val:
            try:
                if re.search(desc, overall_status_val, re.IGNORECASE):
                    target_labels.add(name)
                elif name in existing_labels:
                    labels_to_remove.append(name)
            except re.error:
                pass

    # Remove outdated dimension labels
    for rem in labels_to_remove:
        try:
            encoded_label = urllib.parse.quote(rem)
            github_api_request(
                f"{api_base}/issues/{issue_number}/labels/{encoded_label}",
                method="DELETE",
                token=token,
            )
        except Exception as e:
            print(f"Could not remove label {rem}: {e}")

    # Add target labels
    labels_to_add = [lbl for lbl in target_labels if lbl not in existing_labels]
    if labels_to_add:
        print(f"Adding labels to #{issue_number}: {labels_to_add}")
        github_api_request(
            f"{api_base}/issues/{issue_number}/labels",
            method="POST",
            data={"labels": labels_to_add},
            token=token,
        )

    # 5. Check for existing related compatibility reports (same OS + GPU vendor + model)
    all_compat_issues = []
    page = 1
    while True:
        url = f"{api_base}/issues?state=all&labels=type:compatibility&per_page=100&page={page}"
        batch = github_api_request(url, token=token)
        if not batch:
            break
        all_compat_issues.extend(batch)
        if len(batch) < 100:
            break
        page += 1

    related_issues = []
    for other in all_compat_issues:
        other_num = other.get("number")
        if other_num == issue_number:
            continue
        if "pull_request" in other:
            continue

        other_body = other.get("body", "")
        other_os = extract_heading_value(other_body, ["Host Operating System"])
        other_gpu_vendor = extract_heading_value(other_body, ["GPU Vendor", "GPU Manufacturer / Vendor"])
        other_gpu_model = extract_heading_value(other_body, ["GPU Model"])

        if not (other_os and other_gpu_vendor and other_gpu_model):
            m = re.match(r"^\[Compatibility\]:\s*([^|]+)\s*\|\s*(\S+)\s+(.+)$", other.get("title", ""))
            if m:
                other_os = m.group(1).strip()
                other_gpu_vendor = m.group(2).strip()
                other_gpu_model = m.group(3).strip()

        if other_os and other_gpu_vendor and other_gpu_model:
            other_os_clean = re.sub(r"\s*\([^)]*\)", "", other_os).strip()
            same_os = other_os_clean.lower() == os_clean.lower()
            same_vendor = other_gpu_vendor.strip().lower() == gpu_vendor_val.strip().lower()
            same_gpu = gpu_models_match(gpu_model_val, other_gpu_model)

            if same_os and same_vendor and same_gpu:
                related_issues.append(other)

    if related_issues:
        print(f"Found {len(related_issues)} related reports for #{issue_number}.")
        comments = github_api_request(f"{api_base}/issues/{issue_number}/comments", token=token) or []
        already_commented = any("<!-- automated-related-reports -->" in c.get("body", "") for c in comments)

        if not already_commented:
            comment_lines = [
                "<!-- automated-related-reports -->",
                "### 🔗 Related Compatibility Reports Found",
                "",
                (
                    f"We found existing compatibility report(s) for the same **{os_clean}** + "
                    f"**{gpu_vendor_val}** (`{gpu_model_val}`) combination:"
                ),
                "",
            ]
            for rel in related_issues:
                rel_num = rel.get("number")
                rel_title = rel.get("title")
                rel_user = rel.get("user", {}).get("login", "unknown")
                rel_state = rel.get("state", "open").capitalize()
                comment_lines.append(f"- #{rel_num} - **{rel_title}** (Status: `{rel_state}`) by @{rel_user}")

            comment_lines.extend(
                [
                    "",
                    (
                        "Feel free to check these related reports for shared configuration settings, "
                        "driver notes, or workarounds!"
                    ),
                ]
            )

            github_api_request(
                f"{api_base}/issues/{issue_number}/comments",
                method="POST",
                data={"body": "\n".join(comment_lines)},
                token=token,
            )


def main():
    token = os.environ.get("GITHUB_TOKEN")
    owner = os.environ.get("REPO_OWNER")
    repo = os.environ.get("REPO_NAME")
    issue_number_str = os.environ.get("ISSUE_NUMBER")
    event_name = os.environ.get("EVENT_NAME", "issues")
    action_name = os.environ.get("ACTION_NAME", "")

    if not (token and owner and repo and issue_number_str):
        print(
            "Missing required environment variables: GITHUB_TOKEN, REPO_OWNER, REPO_NAME, ISSUE_NUMBER", file=sys.stderr
        )
        sys.exit(1)

    issue_number = int(issue_number_str)
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

    if event_name == "issue_comment" and action_name == "created":
        handle_issue_comment(owner, repo, issue_number, token)
    else:
        handle_compatibility_issue(owner, repo, issue_number, token, repo_root)


if __name__ == "__main__":
    main()
