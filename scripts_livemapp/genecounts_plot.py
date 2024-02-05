import sys
import matplotlib
import matplotlib.pyplot as plt
import plotly
import plotly.express as px
import pandas as pd
import numpy as np
import plotly.graph_objs as go
import plotly.offline as pyo
# pip install IPython
# pip install -U kaleido
import plotly.io as pio
from IPython.display import HTML
from matplotlib.colors import ListedColormap

import matplotlib.pylab as plt
# pip install watchdog
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from matplotlib.animation import FuncAnimation
import mplcursors
from tkinter import Scrollbar
# pip install --upgrade mplcursors


# Get the path to the TSV file from the command-line arguments path_to_tsv + '/genecount_table.tsv' = SHARED_FOLDER/genecount_table.tsv="/media/localarchive/ONT-data/real-time-tests"/"$1"/genecount_table.tsv
path_to_tsv = sys.argv[1]
# Reading the data from the tsv file
filtered_df = pd.read_csv(path_to_tsv + '/genecount_table.tsv', sep=',')

# Plotting the first frame
fig, ax = plt.subplots()
plt.subplots_adjust(left=0.28, right=0.98, bottom=0.1, top=0.9, wspace=0.4, hspace=0.4)
# np.random.seed(0)
colors = np.random.choice(['b', 'g', 'r', 'c', 'm', 'y', 'k'], len(filtered_df['GeneName'].astype('category')))
lines = []
for i, gene in enumerate(filtered_df['GeneName'].unique()):
    line, = ax.plot(filtered_df[filtered_df['GeneName'] == gene]['Cycle'].to_numpy(), filtered_df[filtered_df['GeneName'] == gene]['GeneCount'].to_numpy(), color=colors[i], label=gene)
    lines.append(line)
ax.set_ylim(auto=True)
#ax.legend(handles=lines, loc='upper right')
ax.legend(handles=lines, loc='upper left', bbox_to_anchor=(-0.4, 1))


# Adding hover annotations
cursor = mplcursors.cursor(lines)
@cursor.connect("add")
def on_add(sel):
    cycle = int(sel.target[0])
    gene_count = int(sel.target[1])
    gene_name = filtered_df.loc[(filtered_df['Cycle'] == cycle) & (filtered_df['GeneCount'] == gene_count), 'GeneName'].values
    if len(gene_name) > 0:
        sel.annotation.set_text(f"Cycle: {cycle}\nGeneCount: {gene_count}\nGeneName: {gene_name[0]}")

# Starting the watchdog observer
event_handler = FileSystemEventHandler()
observer = Observer()

observer.schedule(event_handler, path=path_to_tsv, recursive=False)
observer.start()

# The update function
def update(frame):
    # Reading the data from the excel file
    filtered_df = pd.read_csv(path_to_tsv + '/genecount_table.tsv', sep=',')

    lines = []
    # Removing the older graph
    for line in lines:
        line.remove()

    # Plotting newer graph

    for i, gene in enumerate(filtered_df['GeneName'].unique()):
        line, = ax.plot(filtered_df[filtered_df['GeneName'] == gene]['Cycle'].to_numpy(), filtered_df[filtered_df['GeneName'] == gene]['GeneCount'].to_numpy(), color=colors[i], label=gene)
        lines.append(line)
    ax.set_xlim(filtered_df['Cycle'].iloc[0], filtered_df['Cycle'].iloc[-1])
    ax.autoscale()

    # Updating the legend
    #handles, labels = ax.get_legend_handles_labels()

    cursor = mplcursors.cursor(lines)
    @cursor.connect("add")
    def on_add(sel):
        cycle = int(sel.target[0])
        gene_count = int(sel.target[1])
        gene_name = filtered_df.loc[
            (filtered_df['Cycle'] == cycle) & (filtered_df['GeneCount'] == gene_count), 'GeneName'].values
        if len(gene_name) > 0:
            sel.annotation.set_text(f"Cycle: {cycle}\nGeneCount: {gene_count}\nGeneName: {gene_name[0]}")

    #ax.legend(handles, labels, loc='upper left', bbox_to_anchor=(1.05, 1))

cursor.remove()

# Starting the animation
ani = FuncAnimation(fig, update, frames=None, repeat=True, interval=3000, save_count=1000) # interval=10000 = 10 seconds and 3000 = 3 sec
plt.show()


# Stopping the watchdog observer
observer.stop()
observer.join()