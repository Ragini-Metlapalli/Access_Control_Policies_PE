import os
import re
import pandas as pd
import matplotlib.pyplot as plt


RESULTS_FILE = "merged.csv"
PLOTS_DIR = "plots"
SHOW_PLOTS = False

os.makedirs(PLOTS_DIR, exist_ok=True)

df = pd.read_csv(RESULTS_FILE)

# Extract numeric policy number (P14 -> 14)
df["policy_num"] = (
    df["policy_ids"]
    .str.extract(r"P(\d+)")
    .astype(int)
)

# Only WITH_RLS rows (policy applied)
data = df[df["mode"] == "WITH_RLS"].copy()

# Sort by policy number
data = data.sort_values("policy_num")

# Helper for labels
def add_bar_labels(ax, x_vals, y_vals, fmt="{:.2f}"):
    for x, y in zip(x_vals, y_vals):
        ax.text(
            x,
            y,
            fmt.format(y),
            ha="center",
            va="bottom",
            fontsize=8
        )

#Aggregate per policy (average over runs)
agg = (
    data.groupby("policy_num")
    .mean(numeric_only=True)
    .reset_index()
)

agg = agg.sort_values("policy_num")

# Create evenly spaced x positions
agg["xpos"] = range(len(agg))


#Execution Time (seconds)
agg["elapsed_sec"] = agg["elapsed_ms"] / 1000.0

fig, ax = plt.subplots(figsize=(24, 6))  # wider figure
ax.bar(agg["xpos"], agg["elapsed_sec"], width=0.5)

ax.set_xlabel("Policy")
ax.set_ylabel("Execution Time (seconds)")
ax.set_title("Execution Time per Policy (Query 21)")

# Label as P1, P2, ...
ax.set_xticks(agg["xpos"])
ax.set_xticklabels(
    ["P" + str(p) for p in agg["policy_num"]],
    rotation=60,
    ha="right"
)

add_bar_labels(ax, agg["xpos"], agg["elapsed_sec"], "{:.2f}")

plt.tight_layout()
plt.savefig(f"{PLOTS_DIR}/q21_policy_execution_time.png", dpi=300)
plt.close(fig)



#Logical Reads (x10^3)
agg["logical_reads_k"] = agg["logical_reads"] / 1000.0

fig, ax = plt.subplots(figsize=(30, 6))
ax.bar(agg["xpos"], agg["logical_reads_k"], color="orange", width=0.5)

ax.set_xlabel("Policy")
ax.set_ylabel("Logical Reads (x10³)")
ax.set_title("Logical Reads per Policy (Query 21)")

ax.set_xticks(agg["xpos"])
ax.set_xticklabels(
    ["P" + str(p) for p in agg["policy_num"]],
    rotation=60,
    ha="right"
)

add_bar_labels(ax, agg["xpos"], agg["logical_reads_k"], "{:.1f}")

plt.tight_layout()
plt.savefig(f"{PLOTS_DIR}/q21_policy_logical_reads.png", dpi=300)
plt.close(fig)


# Read-Ahead Reads (x10^3)
agg["read_ahead_k"] = agg["read_ahead_reads"] / 1000.0

fig, ax = plt.subplots(figsize=(24, 6))
ax.bar(agg["xpos"], agg["read_ahead_k"], color="purple", width=0.5)

ax.set_xlabel("Policy")
ax.set_ylabel("Read-Ahead Reads (x10³)")
ax.set_title("Read-Ahead Reads per Policy (Query 21)")

ax.set_xticks(agg["xpos"])
ax.set_xticklabels(
    ["P" + str(p) for p in agg["policy_num"]],
    rotation=60,
    ha="right"
)

add_bar_labels(ax, agg["xpos"], agg["read_ahead_k"], "{:.1f}")

plt.tight_layout()
plt.savefig(f"{PLOTS_DIR}/q21_policy_read_ahead_reads.png", dpi=300)
plt.close(fig)


#Physical Reads (absolute)
fig, ax = plt.subplots(figsize=(24, 6))
ax.bar(agg["xpos"], agg["physical_reads"], color="green",width=0.5 )

ax.set_xlabel("Policy")
ax.set_ylabel("Physical Reads")
ax.set_title("Physical Reads per Policy (Query 21)")

ax.set_xticks(agg["xpos"])
ax.set_xticklabels(
    ["P" + str(p) for p in agg["policy_num"]],
    rotation=60,
    ha="right"
)

add_bar_labels(ax, agg["xpos"], agg["physical_reads"], "{:.0f}")

plt.tight_layout()
plt.savefig(f"{PLOTS_DIR}/q21_policy_physical_reads.png", dpi=300)
plt.close(fig)


print("Plots generated successfully.")
