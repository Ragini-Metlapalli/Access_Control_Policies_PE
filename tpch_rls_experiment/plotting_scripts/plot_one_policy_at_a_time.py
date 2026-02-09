import os
import pandas as pd
import matplotlib.pyplot as plt

RESULTS_FILE = "results/results_all_queries.csv"
PLOTS_DIR = "plots"
SHOW_PLOTS = False

os.makedirs(PLOTS_DIR, exist_ok=True)

df = pd.read_csv(RESULTS_FILE)

# ne-policy-at-a-time runs
policy_df = df[
    (df["mode"] == "WITH_RLS") &
    (df["strategy"] == "MODE2_EXPLICIT")
].copy()

# Extract query number
policy_df["query_num"] = (
    policy_df["query_name"]
    .str.extract(r"(\d+)", expand=False)
    .astype(int)
)

# Extract policy id (single policy guaranteed here)
policy_df["policy_id"] = policy_df["policy_ids"]

# Build x-axis label: "P12 Q3"
policy_df["x_label"] = (
    policy_df["policy_id"] + " Q" + policy_df["query_num"].astype(str)
)

# Sort
policy_df = policy_df.sort_values(["policy_id", "query_num"])

# Helper for bar labels
def add_bar_labels(ax, x_vals, y_vals, fmt="{:.2f}"):
    for x, y in zip(x_vals, y_vals):
        ax.text(x, y, fmt.format(y), ha="center", va="bottom", fontsize=9)

# Aggregate (mean over runs)
grouped = policy_df.groupby("x_label").mean(numeric_only=True).reset_index()

# Execution time (seconds)
grouped["elapsed_sec"] = grouped["elapsed_ms"] / 1000.0

fig, ax = plt.subplots(figsize=(12, 6))
ax.bar(grouped["x_label"], grouped["elapsed_sec"])
ax.set_ylabel("Execution Time (seconds)")
ax.set_title("Execution Time with One Policy Enabled")
ax.set_xlabel("Policy + Query")

add_bar_labels(ax, grouped["x_label"], grouped["elapsed_sec"])
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(f"{PLOTS_DIR}/policy_execution_time_sec.png", dpi=300)
plt.close(fig)

# Logical reads (x10^3)
grouped["logical_reads_k"] = grouped["logical_reads"] / 1000.0

fig, ax = plt.subplots(figsize=(12, 6))
ax.bar(grouped["x_label"], grouped["logical_reads_k"], color="orange")
ax.set_ylabel("Logical Reads (x10³)")
ax.set_title("Logical Buffer Accesses with One Policy Enabled")

add_bar_labels(ax, grouped["x_label"], grouped["logical_reads_k"], fmt="{:.1f}")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(f"{PLOTS_DIR}/policy_logical_reads.png", dpi=300)
plt.close(fig)

# Physical reads (absolute)
fig, ax = plt.subplots(figsize=(12, 6))
ax.bar(grouped["x_label"], grouped["physical_reads"], color="green")
ax.set_ylabel("Physical Reads")
ax.set_title("Physical Disk Reads with One Policy Enabled")

add_bar_labels(ax, grouped["x_label"], grouped["physical_reads"], fmt="{:.0f}")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(f"{PLOTS_DIR}/policy_physical_reads_absolute.png", dpi=300)
plt.close(fig)

# Read-ahead reads (x10^3)
grouped["read_ahead_k"] = grouped["read_ahead_reads"] / 1000.0

fig, ax = plt.subplots(figsize=(12, 6))
ax.bar(grouped["x_label"], grouped["read_ahead_k"], color="purple")
ax.set_ylabel("Read-Ahead Reads (x10³)")
ax.set_title("Read-Ahead Disk Reads with One Policy Enabled")

add_bar_labels(ax, grouped["x_label"], grouped["read_ahead_k"], fmt="{:.1f}")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(f"{PLOTS_DIR}/policy_read_ahead_reads.png", dpi=300)
plt.close(fig)

#  Combined reads (physical + read-ahead, x10^3)
grouped["combined_reads_k"] = (
    grouped["physical_reads"] + grouped["read_ahead_reads"]
) / 1000.0

fig, ax = plt.subplots(figsize=(12, 6))
ax.bar(grouped["x_label"], grouped["combined_reads_k"], color="teal")
ax.set_ylabel("Combined Disk Reads (x10³)")
ax.set_title("Combined Disk Reads with One Policy Enabled")

add_bar_labels(ax, grouped["x_label"], grouped["combined_reads_k"], fmt="{:.1f}")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(f"{PLOTS_DIR}/policy_combined_disk_reads.png", dpi=300)
plt.close(fig)

