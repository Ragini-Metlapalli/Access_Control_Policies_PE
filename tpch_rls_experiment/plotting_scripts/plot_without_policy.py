import os
import pandas as pd
import matplotlib.pyplot as plt


RESULTS_FILE = "results/results_multiple_policies_simultaneously_enabled.csv"
PLOTS_DIR = "plots"
SHOW_PLOTS = False

os.makedirs(PLOTS_DIR, exist_ok=True)

df = pd.read_csv(RESULTS_FILE)

# Baseline only
df["query_num"] = df["query_name"].str.extract(r"(\d+)").astype(int)

# Baseline only (NO RLS)
baseline = df[df["mode"] == "WITH_RLS"].copy()
# baseline = df[df["mode"] == "NO_RLS"].copy()


# Sort baseline by query number
baseline = baseline.sort_values("query_num")


def add_bar_labels(ax, x_vals, y_vals, fmt="{:.2f}"):
    for x, y in zip(x_vals, y_vals):
        ax.text(
            x,
            y,
            fmt.format(y),
            ha="center",
            va="bottom",
            fontsize=9
        )



# Baseline execution time
agg_time = (
    baseline.groupby("query_num")["elapsed_ms"]
    .mean()
    .reset_index()
)

agg_time["elapsed_sec"] = agg_time["elapsed_ms"] / 1000.0

fig, ax = plt.subplots(figsize=(12, 6))
ax.bar(agg_time["query_num"], agg_time["elapsed_sec"])
ax.set_xlabel("TPC-H Query Number")
ax.set_ylabel("Execution Time (seconds)")
# ax.set_title("Baseline Execution Time of TPC-H Queries (No RLS)")
ax.set_title("Execution Time with Multiple Policies Enabled")
ax.set_xticks(agg_time["query_num"])

add_bar_labels(
    ax,
    agg_time["query_num"],
    agg_time["elapsed_sec"]
)


plt.tight_layout()
# plt.savefig(f"{PLOTS_DIR}/baseline_execution_time_sec.png", dpi=300)
plt.savefig(f"{PLOTS_DIR}/execution_time_sec.png", dpi=300)
if SHOW_PLOTS:
    plt.show()
plt.close(fig)


# Baseline logical reads
agg_logical = (
    baseline.groupby("query_num")["logical_reads"]
    .mean()
    .reset_index()
)

fig, ax = plt.subplots(figsize=(12, 6))
agg_logical["logical_reads_k"] = agg_logical["logical_reads"] / 1000.0
ax.bar(
    agg_logical["query_num"],
    agg_logical["logical_reads_k"],
    color="orange"
)
ax.set_xlabel("TPC-H Query Number")
ax.set_ylabel("Logical Reads (x10^3)")
# ax.set_title("Baseline Logical Buffer Accesses (No RLS)")
ax.set_title("Logical Buffer accesses with Multiple Policies Enabled")
ax.set_xticks(agg_logical["query_num"])

add_bar_labels(
    ax,
    agg_logical["query_num"],
    agg_logical["logical_reads_k"],
    fmt="{:.1f}"
)



plt.tight_layout()
# plt.savefig(f"{PLOTS_DIR}/baseline_logical_reads.png", dpi=300)
plt.savefig(f"{PLOTS_DIR}/logical_reads.png", dpi=300)
if SHOW_PLOTS:
    plt.show()
plt.close(fig)


#baseline read-ahead reads
agg_readahead = (
    baseline.groupby("query_num")["read_ahead_reads"]
    .mean()
    .reset_index()
)

agg_readahead["read_ahead_k"] = agg_readahead["read_ahead_reads"] / 1000.0

fig, ax = plt.subplots(figsize=(12, 6))
ax.bar(
    agg_readahead["query_num"],
    agg_readahead["read_ahead_k"],
    color="purple"
)

ax.set_xlabel("TPC-H Query Number")
ax.set_ylabel("Read-Ahead Reads (x10³)")
# ax.set_title("Baseline Read-Ahead Disk Reads (No RLS)")
ax.set_title("Read-Ahead Disk Reads with Multiple Policies Enabled")
ax.set_xticks(agg_readahead["query_num"])

add_bar_labels(
    ax,
    agg_readahead["query_num"],
    agg_readahead["read_ahead_k"],
    fmt="{:.1f}"
)

plt.tight_layout()
# plt.savefig(f"{PLOTS_DIR}/baseline_read_ahead_reads.png", dpi=300)
plt.savefig(f"{PLOTS_DIR}/read_ahead_reads.png", dpi=300)
if SHOW_PLOTS:
    plt.show()
plt.close(fig)



# Baseline physical reads
agg_physical = (
    baseline.groupby("query_num")["physical_reads"]
    .mean()
    .reset_index()
)

fig, ax = plt.subplots(figsize=(12, 6))
ax.bar(
    agg_physical["query_num"],
    agg_physical["physical_reads"],
    color="green"
)

ax.set_xlabel("TPC-H Query Number")
ax.set_ylabel("Physical Reads")
# ax.set_title("Baseline Physical Reads (No RLS)")
ax.set_title("Physical Reads with Multiple Policies Enabled")
ax.set_xticks(agg_physical["query_num"])

add_bar_labels(
    ax,
    agg_physical["query_num"],
    agg_physical["physical_reads"],
    fmt="{:.0f}"
)

plt.tight_layout()
# plt.savefig(f"{PLOTS_DIR}/baseline_physical_reads_absolute.png", dpi=300)
plt.savefig(f"{PLOTS_DIR}/physical_reads_absolute.png", dpi=300)
if SHOW_PLOTS:
    plt.show()
plt.close(fig)


#Baseline combined reads (physical + read-ahead)
agg_combined = (
    baseline.groupby("query_num")[["physical_reads", "read_ahead_reads"]]
    .mean()
    .reset_index()
)

agg_combined["combined_reads"] = (
    agg_combined["physical_reads"] + agg_combined["read_ahead_reads"]
)

agg_combined["combined_reads_k"] = agg_combined["combined_reads"] / 1000.0

fig, ax = plt.subplots(figsize=(12, 6))
ax.bar(
    agg_combined["query_num"],
    agg_combined["combined_reads_k"],
    color="teal"
)

ax.set_xlabel("TPC-H Query Number")
ax.set_ylabel("Combined Disk Reads (x10³)")
# ax.set_title("Baseline Combined Disk Reads (Physical + Read-Ahead)")
ax.set_title("Combined Disk Reads (Physical + Read-Ahead) with Multiple Policies Enabled")
ax.set_xticks(agg_combined["query_num"])

add_bar_labels(
    ax,
    agg_combined["query_num"],
    agg_combined["combined_reads_k"],
    fmt="{:.1f}"
)

plt.tight_layout()
# plt.savefig(f"{PLOTS_DIR}/baseline_combined_disk_reads.png", dpi=300)
plt.savefig(f"{PLOTS_DIR}/combined_disk_reads.png", dpi=300)
if SHOW_PLOTS:
    plt.show()
plt.close(fig)





