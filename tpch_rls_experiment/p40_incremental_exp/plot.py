import pyodbc
import time
import csv
import matplotlib.pyplot as plt

# CONFIG
SERVER = "localhost,1433"
DATABASE = "tpch"
USERNAME = "sa"
PASSWORD = "Saniya@2005"
TIMEOUT_SEC = 180

START = 1
END = 2196
STEP = 10

# reuse from your script
from BS_rowid_p40_p19_q21 import rebuild_policy, run_query21


def run_experiment():
    results = []

    print("\nRunning sweep experiment...\n")

    for window in range(START, END + 1, STEP):
        print(f"Running window = {window}")

        rebuild_policy(window)
        elapsed, timed_out = run_query21(window)

        if timed_out:
            elapsed = TIMEOUT_SEC

        results.append((window, elapsed))

    return results


def save_csv(results):
    with open("q21_window_timing.csv", "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["window_size", "time_sec"])
        writer.writerows(results)

    print("CSV saved: q21_window_timing.csv")


def plot_results(results):
    x = [r[0] for r in results]
    y = [r[1] for r in results]

    plt.figure()
    plt.plot(x, y, marker='o')
    plt.xlabel("Window Size (Rows)")
    plt.ylabel("Execution Time (seconds)")
    plt.title("Q21 Performance vs Window Size (RLS p40+p19)")
    plt.grid()

    plt.savefig("q21_plot.png")
    plt.show()

    print("Plot saved: q21_plot.png")


if __name__ == "__main__":
    results = run_experiment()
    save_csv(results)
    plot_results(results)