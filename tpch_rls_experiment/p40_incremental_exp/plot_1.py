import pandas as pd
import matplotlib.pyplot as plt

# load your csv
df = pd.read_csv("q21_window_timing.csv")

x = df["window_size"]
y = df["time_sec"]

plt.figure(figsize=(14, 14), dpi=150)  # bigger + sharper

plt.scatter(x, y, s=50, alpha=0.7)  # smaller points, slight transparency

plt.xlabel("Window Size (Rows)", fontsize=14)
plt.ylabel("Execution Time (seconds)", fontsize=14)
plt.title("Q21 Performance vs Window Size (RLS p40+p19)", fontsize=16)

plt.grid(True, linestyle='--', alpha=0.5)

plt.tight_layout()

# connect points + show markers
plt.plot(x, y, marker='o', markersize=4, linewidth=1.5)

plt.savefig("q21_high_res_plot_1.png", dpi=300)  # high quality export
plt.show()